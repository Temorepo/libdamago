//
// $Id$

package com.threerings.whirled.contrib.avrg.avatar {

import com.whirled.avrg.AVRGameControl;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

dynamic public class AvatarProxy extends Proxy
{
    public function AvatarProxy (ctrl :AVRGameControl, playerId :int)
    {
        _caller = new AvatarRemoteCaller(ctrl, playerId);
    }

    override flash_proxy function callProperty (name :*, ... args) :*
    {
        args.unshift(name);
        return _caller.apply.apply(_caller, args);
    }

    protected var _caller :AvatarRemoteCaller;
}
}
