package com.threerings.ui.bounds
{
import com.threerings.geom.Vector2;
import com.threerings.geometry.LineSegment;
import com.threerings.util.ClassUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
public class BoundsLine extends Bounds
{
    public function BoundsLine (x1 :Number, y1 :Number, x2 :Number, y2 :Number)
    {
        _p1 = new Vector2(x1, y1);
        _p2 = new Vector2(x2, y2);
        _lineSegment = new LineSegment(_p1, _p2);
    }

    override public function boundingRect () :Rectangle
    {
        var minX :Number = Math.min(_p1.x, _p2.x);
        var maxX :Number = Math.max(_p1.x, _p2.x);
        var minY :Number = Math.min(_p1.y, _p2.y);
        var maxY :Number = Math.max(_p1.y, _p2.y);
        return new Rectangle(minX, minY, maxX - minX, maxY - minY);
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        return LineSegment.distToLineSegment(_p1, _p2, new Vector2(x, y)) == 0;
    }

    override public function debugDraw (s :Sprite) :void
    {
        s.graphics.lineStyle(2, 0xff0000);
        s.graphics.moveTo(_p1.x, _p1.y);
        s.graphics.lineTo(_p2.x, _p2.y);
    }

    override public function distanceToPoint (p :Vector2) :Number
    {
        return LineSegment.distToLineSegment(_p1, _p2, p);
    }

    override public function distance (b :Bounds) :Number
    {
        if (b is BoundsPoint) {
            return distanceToPoint(BoundsPoint(b).point);
        } else if (b is BoundsPolygon) {
//            trace("dist to BoundsPolygon=", BoundsPolygon(b).polygon.distanceToLine(new LineSegment(_p1, _p2)));
//            return BoundsPolygon(b).polygon.distanceToLine(new LineSegment(_p1, _p2));
            return _lineSegment.dist(BoundsPolygon(b).polygon.center);
        } else if (b is BoundsLine) {
            return BoundsLine(b)._lineSegment.distanceToLine(_lineSegment);
        }
        throw new Error("Distance not implemented between " + ClassUtil.tinyClassName(this) +
            " and " + ClassUtil.tinyClassName(b));

    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return LineSegment.closestPoint(_p1, _p2, new Vector2(x, y)).toPoint();
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
        targetY :Number) :Point
    {
        return getBoundedPoint(targetX, targetY);
    }

//    override public function translate (dx :Number, dy :Number) :Bounds
//    {
//        return new BoundsLine(_p1.x + dx, _p1.y + dy, _p2.x + dx, _p2.y + dy);
//    }
//
//    override public function scale (scaleX :Number, scaleY :Number) :Bounds
//    {
//        return new BoundsLine(_p1.x * scaleX, _p1.y * scaleY, _p2.x * scaleX, _p2.y * scaleY);
//    }

    override public function convertToGlobal (localDisp :DisplayObject) :Bounds
    {
        var p1 :Vector2 = Vector2.fromPoint(localDisp.localToGlobal(_p1.toPoint()));
        var p2 :Vector2 = Vector2.fromPoint(localDisp.localToGlobal(_p2.toPoint()));
        return new BoundsLine(p1.x, p1.y, p2.x, p2.y);
    }

    public function get lineSegment () :LineSegment
    {
        return _lineSegment;
    }

    override public function get center () :Vector2
    {
        return Vector2.interpolate(_p1, _p2, 0.5);
    }

    protected var _p1 :Vector2;
    protected var _p2 :Vector2;
    protected var _lineSegment :LineSegment;
}
}
