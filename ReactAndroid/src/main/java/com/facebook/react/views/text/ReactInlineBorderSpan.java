/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package com.facebook.react.views.text;

import android.graphics.Paint;
import android.text.style.LineBackgroundSpan;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Color;
import android.graphics.Path;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.PixelUtil;

/**
 * We use a custom {@link LineBackgroundSpan}, because RN Text component can't render borders. Details here:
 * https://github.com/Expensify/App/issues/4733
 */
public class ReactInlineBorderSpan implements LineBackgroundSpan, ReactSpan {
  private final int effectiveStart;
  private final int effectiveEnd;
  private final int effectiveFontSize;

  private int backgroundColor;
  private int borderColor;
  private int borderRadius;
  private int borderWidth;

  public ReactInlineBorderSpan(int effectiveFontSize, int effectiveStart, int effectiveEnd, ReadableMap textCodeBlock) {
    this.effectiveFontSize = effectiveFontSize;
    this.effectiveStart = effectiveStart;
    this.effectiveEnd = effectiveEnd;
    
    if (textCodeBlock.hasKey("backgroundColor") && !textCodeBlock.isNull("backgroundColor")) {
      this.backgroundColor = Color.parseColor(textCodeBlock.getString("backgroundColor"));
    }
    if (textCodeBlock.hasKey("borderColor") && !textCodeBlock.isNull("borderColor")) {
      this.borderColor = Color.parseColor(textCodeBlock.getString("borderColor"));
    }
    if (textCodeBlock.hasKey("borderRadius") && !textCodeBlock.isNull("borderRadius")) {
      this.borderRadius = (int) PixelUtil.toPixelFromDIP((float) textCodeBlock.getInt("borderRadius"));
    }
    if (textCodeBlock.hasKey("borderWidth") && !textCodeBlock.isNull("borderWidth")) {
      this.borderWidth = textCodeBlock.getInt("borderWidth");
    }
  }

  /**
   * Calculates text start and end position per given lines text range
   */
  private int[] calculateBorderedTextCharRange(int lineStart, int lineEnd) {
    /**
     * If bordered text's position falls within the lines size range return the position of bordered text's first char
     * Otherwise return lines start position.
     * 
     * e.g. given paragraph below:
     * This is a sample text [and the bordered | prependedTextStart -> 23, prependedTextEnd -> 39
     * text starts and ends here].             | prependedTextStart -> 24, prependedTextEnd -> 65
     */
    int prependedTextStart = (lineStart < this.effectiveStart && lineEnd > this.effectiveStart) ? this.effectiveStart : lineStart;
    int prependedTextEnd = (lineEnd < effectiveEnd) ? lineEnd : effectiveEnd;

    return new int[]{prependedTextStart, prependedTextEnd};
  }

  /**
   * Generate Rect that will be used to cover bordered background layer.
   */
  private RectF generateTextBounds(Canvas canvas, Paint paint, int left, int right, int top, int baseline, int bottom, CharSequence text, int start, int end, int lineNumber) {
    int[] borderedTextRange = this.calculateBorderedTextCharRange(start, end);
    
    /**
     * Set's RN Text size for the canvas to measure accurate metrics
     * Calculate bordered text's background layer position relative to the line.
     * 
     * e.g. given the line below
     * This is a prepended [this is bordered] text.
     */
    paint.setTextSize(this.effectiveFontSize + PixelUtil.toPixelFromDIP(2));
    int prependedTextWidth = Math.round(paint.measureText(text, start, borderedTextRange[0]));
    
    paint.setTextSize(this.effectiveFontSize);
    int borderedTextWidth = Math.round(paint.measureText(text, borderedTextRange[0], borderedTextRange[1]));

    RectF rect = new RectF();

    /**
     * Overflow offset to hide border radius on leading lines,
     * so that left border radius is only shown on first and right on last line.
     */
    int offset = (int) PixelUtil.toPixelFromDIP(5f);
    int leftPosition = prependedTextWidth - (lineNumber == 0 ? 0 : offset);
    int rightPosition = prependedTextWidth + borderedTextWidth + (end < effectiveEnd ? offset : 0);
    rect.set(leftPosition, top + borderWidth / 2, rightPosition, bottom - borderWidth / 2);

    return rect;
  }

  /**
   * Generate border radius for each line.
   */
  private float[] generateTextCorners(Canvas canvas, Paint paint, int left, int right, int top, int baseline, int bottom, CharSequence text, int start, int end, int lineNumber) {
    if (lineNumber == 0 && end >= effectiveEnd) {
      return new float[]{this.borderRadius, this.borderRadius, this.borderRadius, this.borderRadius, this.borderRadius, this.borderRadius, this.borderRadius, this.borderRadius};
    }

    if (lineNumber == 0 && end <= effectiveEnd) {
      return new float[]{this.borderRadius, this.borderRadius, 0, 0, 0, 0, this.borderRadius, this.borderRadius};
    }

    if (end >= effectiveEnd) {
      return new float[]{0, 0, this.borderRadius, this.borderRadius, this.borderRadius, this.borderRadius, 0, 0};
    }

    return new float[]{0, 0, 0, 0, 0, 0, 0, 0};
  }


  @Override
  public void drawBackground(Canvas canvas, Paint paint, int left, int right, int top, int baseline, int bottom, CharSequence text, int start, int end, int lineNumber) {
    float[] corners = generateTextCorners(canvas, paint, left, right, top, baseline, bottom, text, start, end, lineNumber);
    final Path path = new Path();

    RectF rect = generateTextBounds(canvas, paint, left, right, top, baseline, bottom, text, start, end, lineNumber);
    path.addRoundRect(rect, corners, Path.Direction.CW);

    /**
     * Draw filled background 
     */
    Paint backgroundPaint = new Paint();
    backgroundPaint.setColor(this.backgroundColor);
    backgroundPaint.setStyle(Paint.Style.FILL);
    canvas.drawPath(path, backgroundPaint);

    /**
     * Draw border
     */
    Paint borderPaint = new Paint();
    borderPaint.setColor(this.borderColor);
    borderPaint.setStyle(Paint.Style.STROKE);
    borderPaint.setStrokeWidth(this.borderWidth);
    borderPaint.setStrokeCap(Paint.Cap.ROUND);
    canvas.drawPath(path, borderPaint);
  }
}
