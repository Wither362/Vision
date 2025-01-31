package vision.algorithms;

import vision.ds.Int16Point2D;
import vision.ds.Line2D;
import vision.ds.Image;
import vision.ds.IntPoint2D;

/**
 * An iterative, partially recursive line detection implementation by [Shahar Marcus](https://www.github.com/ShaharMS).
 */
class SimpleLineDetector {
	public static var image:Image;

	public static function findLineFromPoint(point:Int16Point2D, minLineLength:Float, filterMaximums:Bool = true):Line2D {

		if (image.getUnsafePixel(point.x, point.y) == 0) return null;

		final startX = point.x, startY = point.y;
		var preferTTB = true;
		var candidates:Array<Line2D> = [];

		for (xArr in [[0, 1, 2], [0, -1, -2]]) {
			for (yArr in [[0, 1, 2], [0, -1, -2]]) {
				// now, were going to start looking for points around the point to find the entire line.
				var prev:Null<Int16Point2D> = null;
				var prev2:Null<Int16Point2D> = null;
				var currentDirection:Null<Int16Point2D> = p();
				function expand() {
					if (currentDirection != null
						&& image.hasPixel(point.x + currentDirection.x, point.y + currentDirection.y)
						&& image.getPixel(point.x + currentDirection.x, point.y + currentDirection.y).red == 255) {
						point.x = point.x + currentDirection.x;
						point.y = point.y + currentDirection.y;
						// cachedPoints[ttb | rtl << 1].push(point.copy());

						// used to prevent infinite recursion
						if (prev == null) {
							prev = p(point.x, point.y);
						} else {
							prev2 = p(prev.x, prev.y);
							prev = p(point.x, point.y);
						}
						if ((if (preferTTB) currentDirection.y else currentDirection.x) == 0) {
							if ((point.x == prev.x && point.y == prev.y) || (point.x == prev2.x && point.y == prev2.y)) {
								return;
							}
						}
						expand();
					} else { // fallback, used for skewed/dotted/dashed lines
						for (X in xArr) {
							for (Y in yArr) {
								if (X == 0 && Y == 0 || !image.hasPixel(point.x + X, point.y + Y)) continue;
								if (image.getPixel(point.x + X, point.y + Y).red == 255) {
									currentDirection = p(X, Y);
									point.x = point.x + X;
									point.y = point.y + Y;
									// cachedPoints[ttb | rtl << 1].push(point.copy());

									// used to prevent infinite recursion
									if (prev == null) {
										prev = p(point.x, point.y);
									} else {
										prev2 = p(prev.x, prev.y);
										prev = p(point.x, point.y);
									}
									if ((if (preferTTB) Y else X) == 0) {
										if ((point.x == prev.x && point.y == prev.y) || (point.x == prev2.x && point.y == prev2.y)) {
											return;
										}
									}
									expand();
								}
							}
						}
					}
				}
				expand();
				var line = new Line2D({x: startX, y: startY}, point);

				if (line.length > minLineLength) {
					if (filterMaximums) 
						candidates.push(line);
					else
						return line;
				}
				preferTTB = false;
			}
		}
		if (filterMaximums) {
			candidates.sort((a, b) -> Std.int(a.length - b.length));
			candidates.reverse();
			return candidates[0];
		}
		return null;
	}

	/**
		Returns the percentage of the line that covers an actual line in the given,
		**Black And White** image.
	**/
	public static function lineCoveragePercentage(image:Image, line:Line2D):Float {
		var coveredPixels = 0, totalPixels = 0;
		if (line == null) return 0;
		final p1 = IntPoint2D.fromPoint2D(line.start);
		final p2 = IntPoint2D.fromPoint2D(line.end);
		var x1 = p1.x, y1 = p1.y, x2 = p2.x, y2 = p2.y;
		var dx = Math.abs(x2 - x1);
		var dy = Math.abs(y2 - y1);
		var sx = (x1 < x2) ? 1 : -1;
		var sy = (y1 < y2) ? 1 : -1;
		var err = dx - dy;
		// were going to check for the longest gap using an array of integers
		// each time a gap is getting longer, we'll set the array at the index of the
		// current length of the gap to 1
		// then, the max length should be the length of the array
		var gapChecker:Array<Int> = [];
		var currentGap = 1;
		while (true) {
			if (image.hasPixel(x1, y1)) {
				if (image.getPixel(Std.int(x1), Std.int(y1)).red == 255) {
					coveredPixels++;
					currentGap = 0;
				} else {
					gapChecker[currentGap] = 1;
					currentGap++;
				}
			}
			totalPixels++;
			if (x1 == x2 && y1 == y2) break;
			var e2 = 2 * err;
			if (e2 > -dy) {
				err -= dy;
				x1 += sx;
			}
			if (e2 < dx) {
				err += dx;
				y1 += sy;
			}
		}
		return (coveredPixels /*The biggest gap */ - gapChecker.length) / totalPixels * 100;
	}

	static extern inline function p(x:Int = 0, y:Int = 0) {
		return new Int16Point2D(x, y);
	}

	public function new(image:Image) {}
}

/* Needs Fixing, or removing altogether

	import vision.ds.Int16Point2D;
	import vision.ds.UInt16Point2D;
	import vision.exceptions.VisionException;
	import haxe.display.Display.Package;
	import vision.ds.IntPoint2D;
	import vision.tools.MathTools;
	import vision.ds.Color;
	import vision.ds.Point2D;
	import vision.ds.Line2D;
	import vision.ds.Image;

	using vision.tools.MathTools;
	using vision.tools.ImageTools;

	private typedef S = SimpleLineDetector;
	class SimpleLineDetector {

	public static var image:Image;

	static inline function p(x:Int = 0, y:Int = 0) {
		return new Int16Point2D(x, y);
	}


	public static function findLineFromPoint(point:Int16Point2D, minLineLength:Float, maxGap:Int = 1):Line2D {
		if (!image.hasPixel(point.x, point.y)) return null;
		if (image.getUnsafePixel(point.x, point.y) != 0xFFFFFFFF) return null;
		final start = p(point.x, point.y);
		var pointCheckOrder:Array<Int16Point2D> = [p(1, 0), p(1, 1), p(0, 1), p(-1, 1), p(-1, 0), p(-1, -1), p(0, -1), p(1, -1)];
		var cwp:Null<Int16Point2D> = p(point.x, point.y);
		var safetyNet = 0;
		var voided:Bool = false;
		// 
		// A positive/negative integer, calculated during the processing of the first few pixels.
		// When positive, the point (0, -1) will be removed from the detection calculations. when negative, the opposite
		// point gets removed.
		// 
		var dir:Float = 0;
		var alreadyGap = false;
		var safeMax = Math.sqrt(image.width * image.width + image.height * image.height);
		var prev:Null<Int16Point2D> = p(-5, -5), prev2:Null<Int16Point2D> = p(-10, -10);
		while (!voided) {
			safetyNet++;
			if (safetyNet == 5 || safetyNet == 10) {
				dir = MathTools.degreesFromPointToPoint2D(start, cwp);
				if (dir.isBetweenRange(0, 90)) {
					pointCheckOrder = [p(1, -1), p(1, 0), p(0, -1), p(-1, -1), p(1, 1)];
				} else if (dir.isBetweenRange(90, 180)) {
					pointCheckOrder = [p(-1, -1), p(-1, 0), p(0, -1), p(-1, 1), p(1, -1)];
				} else if (dir.isBetweenRange(-90, 0)) {
					pointCheckOrder = [p(1, 1), p(1, 0), p(0, 1), p(-1, 1), p(-1, 1)];
				} else {
					pointCheckOrder = [p(-1, 1), p(-1, 0), p(0, 1), p(-1, -1), p(1, 1)];
				}
			}
			if (safetyNet > safeMax || (safetyNet > 10 && (cwp == prev2 || cwp == prev))) break;
			voided = true;
			for (p in pointCheckOrder) {
				if (image.hasPixel(p.x + cwp.x, p.y + cwp.y) && image.getUnsafePixel(p.x + cwp.x, p.y + cwp.y) == 0xFFFFFFFF) {
					cwp = S.p(cwp.x + p.x, cwp.y + p.y);
					prev = cwp;
					prev2 = prev;
					voided = false;
					alreadyGap = false;
				} 
			}
			if (voided && !alreadyGap) {
				dir = MathTools.degreesFromPointToPoint2D(start, cwp);
				if (dir.isBetweenRange(0, 90)) {
					pointCheckOrder = [p(1, -1), p(1, 0), p(0, -1), p(-1, -1), p(1, 1)];
				} else if (dir.isBetweenRange(90, 180)) {
					pointCheckOrder = [p(-1, -1), p(-1, 0), p(0, -1), p(-1, 1), p(1, -1)];
				} else if (dir.isBetweenRange(-90, 0)) {
					pointCheckOrder = [p(1, 1), p(1, 0), p(0, 1), p(-1, 1), p(1, -1)];
				} else {
					pointCheckOrder = [p(-1, 1), p(-1, 0), p(0, 1), p(-1, -1), p(1, 1)];
				}
				voided = false;
				alreadyGap = true;
			}
		}
		var line = new Line2D(start, cwp);
		if (line.length >= minLineLength) {
			return line; 
		}
		return null;
	}

	public static function lineCoveragePercentage(image:Image, line:Line2D):Float {
		var coveredPixels = 0, totalPixels = 0;
		if (line == null)
			return 0;
		final p1 = new UInt16Point2D(Std.int(line.start.x), Std.int(line.start.y));
		final p2 = new UInt16Point2D(Std.int(line.end.x), Std.int(line.end.y));
		var x1 = p1.x, y1 = p1.y, x2 = p2.x, y2 = p2.y;
		var dx = Math.abs(x2 - x1);
		var dy = Math.abs(y2 - y1);
		var sx = (x1 < x2) ? 1 : -1;
		var sy = (y1 < y2) ? 1 : -1;
		var err = dx - dy;
		//were going to check for the longest gap using an array of integers
		//each time a gap is getting longer, we'll set the array at the index of the
		//current length of the gap to 1
		//then, the max length should be the length of the array
		var gapChecker:Array<Int> = [];
		var currentGap = 1;
		while (true) {
			if (image.hasPixel(x1, y1)) {
				if (image.getPixel(Std.int(x1), Std.int(y1)).red == 255) {
					coveredPixels++;
					currentGap = 0;
				} else {
					gapChecker[currentGap] = 1;
					currentGap++;
				}
			}
			totalPixels++;
			if (x1 == x2 && y1 == y2)
				break;
			var e2 = 2 * err;
			if (e2 > -dy) {
				err -= dy;
				x1 += sx;
			}
			if (e2 < dx) {
				err += dx;
				y1 += sy;
			}
		}
		return (
			
			coveredPixels //the biggest gap
			- gapChecker.length) / totalPixels * 100;
	}

	static function depositPoints(x1:Float, y1:Float, x2:Float, y2:Float) {
		var dx = Math.abs(x2 - x1);
		var dy = Math.abs(y2 - y1);
		var sx = (x1 < x2) ? 1 : -1;
		var sy = (y1 < y2) ? 1 : -1;
		var err = dx - dy;
		while (true) {
			//cachedPoints.push(p(x1, y1));
			image.setUnsafePixel(Std.int(x1), Std.int(y1), 0);
			if (x1 == x2 && y1 == y2) break;
			var e2 = 2 * err;
			if (e2 > -dy) {
				err -= dy;
				x1 += sx;
			}
			if (e2 < dx) {
				err += dx;
				y1 += sy;
			}
		}
	}
	}
 */
