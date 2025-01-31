float cursorX, cursorY;
class AimCursor {
  AimCursor() {
    cursorX = width/2 + 30;
    cursorY = height/2;
  }
  public void show() {
    stroke(255, 0, 0);
    strokeWeight(0.8);
    ellipse(cursorX, cursorY, 16, 16);
    line(cursorX, cursorY + 8, cursorX, cursorY + 5);
    line(cursorX, cursorY - 8, cursorX, cursorY - 5);
    line(cursorX + 8, cursorY, cursorX + 5, cursorY);
    line(cursorX - 8, cursorY, cursorX - 5, cursorY);
  }
  public void up() { if ((cursorY - 5) > 0) cursorY -= 5; }
  public void down() { if ((cursorY + 5) < height) cursorY += 5; }
  public void left() { if ((cursorX - 5) > 0) cursorX -= 5; }
  public void right() { if ((cursorX + 5) < width) cursorX += 5; }

  public float getX() { return cursorX; }
  public float getY() { return cursorY; }
}
