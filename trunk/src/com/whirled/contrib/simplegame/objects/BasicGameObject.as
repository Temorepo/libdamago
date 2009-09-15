//
// $Id: BasicGameObject.as 2467 2009-06-10 18:44:02Z nathan $

package com.whirled.contrib.simplegame.objects{

import com.whirled.contrib.EventHandlerManager;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.clearInterval;

public class BasicGameObject extends EventDispatcher
{
    public function shutdown (...ignored) :void
    {
        _events.freeAllHandlers();
        for each (var id :uint in _intervalIds) {
            clearInterval(id);
        }
    }

    public function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0,
        useWeakReference :Boolean = false) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority,
            useWeakReference);
    }

    protected function addIntervalId (id :uint) :void
    {
        _intervalIds.push(id);
    }

    protected var _intervalIds :Array = [];
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}
