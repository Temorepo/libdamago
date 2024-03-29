package com.threerings.flashbang.pushbutton
{
    import com.threerings.flashbang.audio.*;
    import com.threerings.flashbang.resource.*;
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Assert;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.KeyboardEvent;
    
    public class PBEMainLoop extends EventDispatcher
    {
        public static const HAS_STOPPED :String = "HasStopped";
        public static const HAS_SHUTDOWN :String = "HasShutdown";
        
        public function PBEMainLoop (ctx :PBEContext, minFrameRate :Number)
        {
            _ctx = ctx;
            _minFrameRate = minFrameRate;
        }
        
        /**
         * Initializes structures required by the framework.
         */
        public function setup () :void
        {
        }
        
        /**
         * Call this function before the application shuts down to release
         * memory and disconnect event handlers. The MainLoop may not shut down
         * immediately when this function is called - if it is running, it will be
         * shut down at the end of the current update.
         *
         * It's an error to continue to use a MainLoop that has been shut down.
         *
         * Most applications will want to install an Event.REMOVED_FROM_STAGE
         * handler on the main sprite, and call shutdown from there.
         */
        public function shutdown () :void
        {
            if (_running) {
                _shutdownPending = true;
            } else {
                shutdownNow();
            }
        }
        
        public function addUpdatable (obj :Updatable) :void
        {
            _updatables.push(obj);
        }
        
        public function removeUpdatable (obj :Updatable) :void
        {
            ArrayUtil.removeFirst(_updatables, obj);
        }
        
        /**
         * Returns the top mode on the mode stack, or null
         * if the stack is empty.
         */
        public function get topMode () :PBEAppmode
        {
            if (_modeStack.length == 0) {
                return null;
            } else {
                return ((_modeStack[_modeStack.length - 1]) as PBEAppmode);
            }
        }
        
        /**
         * Kicks off the MainLoop. Game updates will start happening after this
         * function is called.
         */
        public function run (hostSprite :Sprite, keyDispatcher :IEventDispatcher = null) :void
        {
            if (_running) {
                throw new Error("already running");
            }
            
            if (null == hostSprite) {
                throw new ArgumentError("hostSprite must not be null");
            }
            
            _hostSprite = hostSprite;
            _keyDispatcher = (null != keyDispatcher ? keyDispatcher : _hostSprite);
            
            // ensure that proper setup has completed
            setup();
            
            _running = true;
            _stopPending = false;
            
            _hostSprite.addEventListener(Event.ENTER_FRAME, update);
            _keyDispatcher.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            _keyDispatcher.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            
            _lastTime = this.elapsedSeconds;
            
            // Handle initial mode transitions made since MainLoop creation
            handleModeTransitions();
        }
        
        /**
         * Stops the MainLoop from running. It can be restarted by calling run() again.
         * The MainLoop may not stop immediately when this function is called -
         * if it is running, it will be stopped at the end of the current update.
         */
        public function stop () :void
        {
            if (_running) {
                _stopPending = true;
            }
        }
        
        /**
         * Applies the specify mode transition to the mode stack.
         * (Mode changes take effect between game updates.)
         */
        public function doModeTransition (type :ModeTransition, mode :PBEAppmode = null, index :int = 0)
            :void
        {
            if (type.requiresMode && mode == null) {
                throw new Error("mode must be non-null for " + type);
            }
            
            var transition :PendingTransition = new PendingTransition();
            transition.type = type;
            transition.mode = mode;
            transition.index = index;
            _pendingModeTransitionQueue.push(transition);
        }
        
        /**
         * Inserts a mode into the stack at the specified index. All modes
         * at and above the specified index will move up in the stack.
         * (Mode changes take effect between game updates.)
         *
         * @param mode the PBEAppmode to add
         * @param index the stack position to add the mode at.
         * You can use a negative integer to specify a position relative
         * to the top of the stack (for example, -1 is the top of the stack).
         */
        public function insertMode (mode :PBEAppmode, index :int) :void
        {
            doModeTransition(ModeTransition.INSERT, mode, index);
        }
        
        /**
         * Removes a mode from the stack at the specified index. All
         * modes above the specified index will move down in the stack.
         * (Mode changes take effect between game updates.)
         *
         * @param index the stack position to add the mode at.
         * You can use a negative integer to specify a position relative
         * to the top of the stack (for example, -1 is the top of the stack).
         */
        public function removeMode (index :int) :void
        {
            doModeTransition(ModeTransition.REMOVE, null, index);
        }
        
        /**
         * Pops the top mode from the stack, if the modestack is not empty, and pushes
         * a new mode in its place.
         * (Mode changes take effect between game updates.)
         */
        public function changeMode (mode :PBEAppmode) :void
        {
            doModeTransition(ModeTransition.CHANGE, mode);
        }
        
        /**
         * Pushes a mode to the mode stack.
         * (Mode changes take effect between game updates.)
         */
        public function pushMode (mode :PBEAppmode) :void
        {
            doModeTransition(ModeTransition.PUSH, mode);
        }
        
        /**
         * Pops the top mode from the mode stack.
         * (Mode changes take effect between game updates.)
         */
        public function popMode () :void
        {
            doModeTransition(ModeTransition.REMOVE, null, -1);
        }
        
        /**
         * Pops all modes from the mode stack.
         * Mode changes take effect before game updates.
         */
        public function popAllModes () :void
        {
            doModeTransition(ModeTransition.UNWIND);
        }
        
        /**
         * Pops modes from the stack until the specified mode is reached.
         * If the specified mode is not reached, it will be pushed to the top
         * of the mode stack.
         * Mode changes take effect before game updates.
         */
        public function unwindToMode (mode :PBEAppmode) :void
        {
            doModeTransition(ModeTransition.UNWIND, mode);
        }
        
        /** Returns the number of seconds that have elapsed since the application started. */
        public function get elapsedSeconds () :Number
        {
            return (flash.utils.getTimer() / 1000); // getTimer() returns a value in milliseconds
        }
        
        /**
         * Returns the approximate frames-per-second that the application
         * is running at.
         */
        public function get fps () :Number
        {
            return _fps;
        }
        
        protected function handleModeTransitions () :void
        {
            if (_pendingModeTransitionQueue.length <= 0) {
                return;
            }
            
            var initialTopMode :PBEAppmode = this.topMode;
            
            function doPushMode (newMode :PBEAppmode) :void {
                if (null == newMode) {
                    throw new Error("Can't push a null mode to the mode stack");
                }
                
                _modeStack.push(newMode);
                _hostSprite.addChild(newMode.modeSprite);
                
                newMode._ctx = _ctx;
                newMode.setupInternal();
            }
            
            function doInsertMode (newMode :PBEAppmode, index :int) :void {
                if (null == newMode) {
                    throw new Error("Can't insert a null mode in the mode stack");
                }
                
                if (index < 0) {
                    index = _modeStack.length + index;
                }
                index = Math.max(index, 0);
                index = Math.min(index, _modeStack.length);
                
                _modeStack.splice(index, 0, newMode);
                _hostSprite.addChildAt(newMode.modeSprite, index);
                
                newMode._ctx = _ctx;
                newMode.setupInternal();
            }
            
            function doRemoveMode (index :int) :void {
                if (_modeStack.length == 0) {
                    throw new Error("Can't remove a mode from an empty stack");
                }
                
                if (index < 0) {
                    index = _modeStack.length + index;
                }
                
                index = Math.max(index, 0);
                index = Math.min(index, _modeStack.length - 1);
                
                // if the top mode is removed, make sure it's exited first
                var mode :PBEAppmode = _modeStack[index];
                if (mode == initialTopMode) {
                    initialTopMode.exitInternal();
                    initialTopMode = null;
                }
                
                mode.destroyInternal();
                mode._ctx = null;
                
                _modeStack.splice(index, 1);
                _hostSprite.removeChild(mode.modeSprite);
            }
            
            // create a new _pendingModeTransitionQueue right now
            // so that we can properly handle mode transition requests
            // that occur during the processing of the current queue
            var transitionQueue :Array = _pendingModeTransitionQueue;
            _pendingModeTransitionQueue = [];
            
            for each (var transition :PendingTransition in transitionQueue) {
                var mode :PBEAppmode = transition.mode;
                switch (transition.type) {
                    case ModeTransition.PUSH:
                        doPushMode(mode);
                        break;
                    
                    case ModeTransition.INSERT:
                        doInsertMode(mode, transition.index);
                        break;
                    
                    case ModeTransition.REMOVE:
                        doRemoveMode(transition.index);
                        break;
                    
                    case ModeTransition.CHANGE:
                        // a pop followed by a push
                        if (null != this.topMode) {
                            doRemoveMode(-1);
                        }
                        doPushMode(mode);
                        break;
                    
                    case ModeTransition.UNWIND:
                        // pop modes until we find the one we're looking for
                        while (_modeStack.length > 0 && this.topMode != mode) {
                            doRemoveMode(-1);
                        }
                        
                        Assert.isTrue(this.topMode == mode || _modeStack.length == 0);
                        
                        if (_modeStack.length == 0 && null != mode) {
                            doPushMode(mode);
                        }
                        break;
                }
            }
            
            var topMode :PBEAppmode = this.topMode;
            if (topMode != initialTopMode) {
                if (null != initialTopMode) {
                    initialTopMode.exitInternal();
                }
                
                if (null != topMode) {
                    topMode.enterInternal();
                }
            }
        }
        
        protected function update (e :Event) :void
        {
            // how much time has elapsed since last frame?
            var newTime :Number = this.elapsedSeconds;
            var dt :Number = newTime - _lastTime;
            
            // If we have pending mode transitions, handle them, and discount
            // the time that it took to perform this processing, so that changing
            // modes doesn't result in stuttery behavior
            if (_pendingModeTransitionQueue.length > 0) {
                handleModeTransitions();
                newTime = this.elapsedSeconds;
                dt = 1 / 30; // Assume 30 fps is our target. Should this be configurable?
            }
            
            if (_minFrameRate > 0) {
                // Ensure that our time deltas don't get too large
                dt = Math.min(1 / _minFrameRate, dt);
            }
            
            _fps = 1 / dt;
            
            // update all our "updatables"
            for each (var updatable :Updatable in _updatables) {
                updatable.update(dt);
            }
            
            // update the top mode
            var theTopMode :PBEAppmode = this.topMode;
            if (null != theTopMode) {
                theTopMode.update(dt);
            }
            
            // should the MainLoop be stopped?
            if (_stopPending || _shutdownPending) {
                _hostSprite.removeEventListener(Event.ENTER_FRAME, update);
                _keyDispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                _keyDispatcher.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
                clearModeStackNow();
                _running = false;
                dispatchEvent(new Event(HAS_STOPPED));
                
                if (_shutdownPending) {
                    shutdownNow();
                }
            }
            
            _lastTime = newTime;
        }
        
        protected function onKeyDown (e :KeyboardEvent) :void
        {
            var topMode :PBEAppmode = this.topMode;
            if (null != topMode) {
                topMode.onKeyDown(e.keyCode);
            }
        }
        
        protected function onKeyUp (e :KeyboardEvent) :void
        {
            var topMode :PBEAppmode = this.topMode;
            if (null != topMode) {
                topMode.onKeyUp(e.keyCode);
            }
        }
        
        protected function clearModeStackNow () :void
        {
            _pendingModeTransitionQueue = [];
            if (_modeStack.length > 0) {
                popAllModes();
                handleModeTransitions();
            }
        }
        
        protected function shutdownNow () :void
        {
            clearModeStackNow();
            
            _ctx = null;
            _hostSprite = null;
            _keyDispatcher = null;
            _modeStack = null;
            _pendingModeTransitionQueue = null;
            _updatables = null;
            
            dispatchEvent(new Event(HAS_SHUTDOWN));
        }
        
        protected var _ctx :PBEContext;
        protected var _minFrameRate :Number;
        protected var _hostSprite :Sprite;
        protected var _keyDispatcher :IEventDispatcher;
        
        protected var _hasSetup :Boolean;
        protected var _running :Boolean;
        protected var _stopPending :Boolean;
        protected var _shutdownPending :Boolean;
        protected var _lastTime :Number;
        protected var _modeStack :Array = [];
        protected var _pendingModeTransitionQueue :Array = [];
        protected var _updatables :Array = [];
        protected var _fps :Number = 0;
    }
    
}

import com.threerings.flashbang.ModeTransition;

class PendingTransition
{
    public var mode :PBEAppmode;
    public var type :ModeTransition;
    public var index :int;
}