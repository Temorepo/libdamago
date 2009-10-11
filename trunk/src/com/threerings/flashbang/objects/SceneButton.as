//
// $Id: SceneButton.as 2467 2009-06-10 18:44:02Z nathan $

package com.threerings.flashbang.objects {
import flash.display.SimpleButton;
public class SceneButton extends SimpleSceneObject
{
    public function SceneButton (button :SimpleButton, name :String = null)
    {
        super(button, name);
        _button = button;
    }

    public function get button () :SimpleButton
    {
        return _button;
    }

    public function get mouseEnabled () :Boolean
    {
        return _button.mouseEnabled;
    }

    public function set mouseEnabled (m :Boolean) :void
    {
        _button.mouseEnabled = m;
    }

    public function registerButtonListener (eventname :String, f :Function) :void
    {
        registerListener(_button, eventname, f);
    }

    protected var _button :SimpleButton;
}
}
