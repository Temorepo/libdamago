package com.threerings.flashbang.pushbutton {
import com.threerings.flashbang.components.SceneComponent;
import com.threerings.util.Log;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import com.threerings.flashbang.pbe.ObjectDBPBE;

public class PBEAppmode extends ObjectDBPBE
{
    public function PBEAppmode ()
    {
        _modeSprite.mouseEnabled = false;
        _modeSprite.mouseChildren = false;
    }
    
    public function get modeSprite () :Sprite
    {
        return _modeSprite;
    }
    
    /** Returns the Context associated with this AppMode. */
    public final function get ctx () :PBEContext
    {
        return _ctx;
    }
    
    /**
     * A convenience function that adds the given SceneObject to the mode and attaches its
     * DisplayObject to the display list.
     *
     * @param displayParent the parent to attach the DisplayObject to, or null to attach
     * directly to the AppMode's modeSprite.
     *
     * @param displayIdx the index at which the object will be added to displayParent,
     * or -1 to add to the end of displayParent
     */
    public function addSceneObject (obj :PBEObject, displayParent :DisplayObjectContainer = null,
                                    displayIdx :int = -1) :EntityRef
    {
        if (!(obj is SceneComponent)) {
            throw new Error("obj must implement SceneComponent");
        }
        
        // Attach the object to a display parent.
        // (This is purely a convenience - the client is free to do the attaching themselves)
        var disp :DisplayObject = (obj as SceneComponent).displayObject;
        if (null == disp) {
            throw new Error("obj must return a non-null displayObject to be attached " +
                "to a display parent");
        }
        
        if (displayParent == null) {
            displayParent = _modeSprite;
        }
        
        if (displayIdx < 0 || displayIdx >= displayParent.numChildren) {
            displayParent.addChild(disp);
        } else {
            displayParent.addChildAt(disp, displayIdx);
        }
        
        return addObject(obj);
    }
    
    override public function destroyObject (ref :EntityRef) :void
    {
        if (null != ref && null != ref.object) {
            // if the object is attached to a DisplayObject, and if that
            // DisplayObject is in a display list, remove it from the display list
            // so that it will no longer be drawn to the screen
            var sc :SceneComponent = (ref.object as SceneComponent);
            if (null != sc) {
                var displayObj :DisplayObject = sc.displayObject;
                if (null != displayObj) {
                    var parent :DisplayObjectContainer = displayObj.parent;
                    if (null != parent) {
                        parent.removeChild(displayObj);
                    }
                }
            }
        }
        
        super.destroyObject(ref);
    }
    
    /** Called when a key is pressed while this mode is active */
    public function onKeyDown (keyCode :uint) :void
    {
    }
    
    /** Called when a key is released while this mode is active */
    public function onKeyUp (keyCode :uint) :void
    {
    }
    
    /** Called when the mode is added to the mode stack */
    protected function setup () :void
    {
    }
    
    /** Called when the mode is removed from the mode stack */
    protected function destroy () :void
    {
    }
    
    /** Called when the mode becomes active on the mode stack */
    protected function enter () :void
    {
    }
    
    /** Called when the mode becomes inactive on the mode stack */
    protected function exit () :void
    {
    }
    
    internal function setupInternal () :void
    {
        setup();
    }
    
    internal function destroyInternal () :void
    {
        destroy();
        shutdown();
    }
    
    internal function enterInternal () :void
    {
        this.modeSprite.mouseEnabled = true;
        this.modeSprite.mouseChildren = true;
        
        enter();
    }
    
    internal function exitInternal () :void
    {
        this.modeSprite.mouseEnabled = false;
        this.modeSprite.mouseChildren = false;
        
        exit();
    }
    
    protected var _modeSprite :Sprite = new Sprite();
    
    // Managed by MainLoop
    internal var _ctx :PBEContext;

    protected static const log :Log = Log.getLog(PBEAppmode);

    
    
}
}