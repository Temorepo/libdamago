package com.threerings.ui.bounds {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;
import com.threerings.util.DebugUtil;
import com.threerings.util.Log;
import com.threerings.util.MathUtil;

public class BoundsPoint extends Bounds
{
    public static const FIXED_ZERO_BOUNDS :BoundsPoint = new BoundsPoint(0, 0);

    public function BoundsPoint (x :Number, y :Number)
    {
        _point = new Vector2(x, y);
    }

    override public function get height () :Number
    {
        return 0;
    }

    override public function get width () :Number
    {
        return 0;
    }

    override public function get center () :Vector2
    {
        return _point;
    }

    public function get point () :Vector2
    {
        return _point;
    }

    override public function boundingRect () :Rectangle
    {
        return new Rectangle(_point.x, _point.y, 0, 0);
    }

    override public function clone () :Object
    {
        return new BoundsPoint(_point.x, _point.y);
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        return _point.x == x && _point.y == y;
    }

    override public function convertToGlobal (localDisp :DisplayObject) :Bounds
    {
        var p1 :Point = localDisp.localToGlobal(_point.toPoint());
        return new BoundsPoint(p1.x, p1.y);
    }

    override public function debugDraw (s :Sprite) :void
    {
        DebugUtil.drawDot(s, 0xff0000, 4, _point.x, _point.y);
    }

    override public function distance (b :Bounds) :Number
    {
        if (b is BoundsPoint) {
            return distanceToPoint(BoundsPoint(b).point);
        } else if (b is BoundsPolygon) {
            return distanceToPoint(BoundsPolygon(b).polygon.center);
        } else if (b is BoundsLine) {
            return BoundsLine(b).lineSegment.dist(_point);
        }
        throw new Error("Distance not implemented between " + ClassUtil.tinyClassName(this) +
            " and " + ClassUtil.tinyClassName(b));

    }

    override public function distanceToPoint (p :Vector2) :Number
    {
        return MathUtil.distance(p.x, p.y, _point.x, _point.y);
    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return _point.toPoint();
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number,
        targetX :Number, targetY :Number) :Point
    {
        return _point.toPoint();
    }

    public function toString () :String
    {
        return ClassUtil.tinyClassName(BoundsPoint) + "[" + _point + "]";
    }

    protected var _point :Vector2;

    protected static const log :Log = Log.getLog(BoundsPoint);


}
}
