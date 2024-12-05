ArrayList <Particle> particles = new ArrayList <Particle>();
// int[] particles = new int[1000];
float aimX, aimY; // where the system is aiming
float bulletSpeed = 50;
float aimSpeed = 0.8; // how fast the aimpoint moves, 1 is instantaneous
float reloadTime = 2.5; // frames between shots
int framesSinceLastShot = 0;
int shotsSinceLastTracer = 0;
float anchorX, anchorY;
PVector prevMousePos;
PVector avgVelocity = new PVector(0, 0);
int velocitySampleSize = 20; // number of frames to average velocity over
float jitterAmount = 4.0; // Adjust this value for more or less jitter
float jitterX, jitterY;

class Particle {
    float x, y, vx, vy;
    float angle = atan2(vy, vx);
    int[] colo = new int[3];

    Particle(float x, float y, float angle) {
        this.x = x;
        this.y = y;
        this.vx = bulletSpeed * cos(angle);
        this.vy = bulletSpeed * sin(angle);
        this.colo[0] = 55;
        this.colo[1] = 55;
        this.colo[2] = 55;
    }

    void move() {
        x += vx;
        y += vy;
    }

    void show() {
        stroke(colo[0], colo[1], colo[2]);
        strokeWeight(2);
        noFill();
        line(x, y, x - vx / 2, y - vy / 2);
    }
    // setter for color
    void setColor(int r, int g, int b) {
        colo[0] = r;
        colo[1] = g;
        colo[2] = b;
    }

    boolean isOffScreen() {
        return x < 0 || x > width || y < 0 || y > height;
    }

    boolean isNearMouse() {
        return dist(x, y, mouseX, mouseY) < 10;
    }
}

class Oddball extends Particle {
    Oddball(float x, float y, float angle) {
        super(x, y, angle);
    }

    @Override
    void show() {
        stroke(0, 255, 0);
       // strokeWeight(2);
       // noFill();
       // line(x - vx / 1.5, y - vy / 1.5, x, y); // Draw tracer round
    }
}

void setup() {
    frameRate(120);
    size(960, 540);
    anchorX = 50;
    anchorY = height - 50;
    aimX = anchorX; // initialize aim point to anchor point
    aimY = anchorY;
    prevMousePos = new PVector(mouseX, mouseY);
}

void draw() {
    background(0);
// 
//     // calculate average mouse velocity
//     PVector mouse = new PVector(mouseX, mouseY);
//     PVector mouseVelocity = new PVector(mouse.x - prevMousePos.x, mouse.y - prevMousePos.y);
//     avgVelocity.x += (mouseVelocity.x - avgVelocity.x) * (1.0 / velocitySampleSize);
//     avgVelocity.y += (mouseVelocity.y - avgVelocity.y) * (1.0 / velocitySampleSize);
//     // controls how fast the average velocity changes
// 
//     prevMousePos.set(mouse);
// 
//     float distanceToMouse = dist(anchorX, anchorY, mouseX, mouseY);
//     float leadTime = distanceToMouse / bulletSpeed; // how far to lead by
// 
//     float leadX = mouseX + avgVelocity.x * leadTime;
//     float leadY = mouseY + avgVelocity.y * leadTime;
// 
// 
//     // calculate aim point coords
//     aimX += (leadX - aimX) * aimSpeed;
//     aimY += (leadY - aimY) * aimSpeed;
//     aimX += jitterX;
//     aimY += jitterY;
// 
//     // draw aim line
//     stroke(255, 0, 0);
//     strokeWeight(1);
//     line(anchorX, anchorY, aimX, aimY);
// 
//     if (framesSinceLastShot >= reloadTime) {
//         fire();
//         framesSinceLastShot = 0;
//     }
// 
//     framesSinceLastShot++;
// 
//     for (int i = particles.size() - 1; i >= 0; i--) {
//         Particle p = particles.get(i);
//         p.move();
//         p.show();
// 
//         if (p.isOffScreen()) {
//             particles.remove(i); // remove offscreen particles;
//         }
// 
//         if (p.isNearMouse()) {
//             p.setColor(10, 10, 10);
//         }
//     }
}

void fire() {
    float angle = atan2(aimY - anchorY, aimX - anchorX);

    if (shotsSinceLastTracer >= 5) {
        Oddball newOddball = new Oddball(anchorX, anchorY, angle);
        newOddball.setColor(0, 255, 255);
        particles.add(newOddball);
        shotsSinceLastTracer = 0;
        jitterX = random(-jitterAmount, jitterAmount);
        jitterY = random(-jitterAmount, jitterAmount);
    } else {
        Particle newParticle = new Particle(anchorX, anchorY, angle);
        particles.add(newParticle);
        shotsSinceLastTracer++;
        jitterX = random(-jitterAmount, jitterAmount);
        jitterY = random(-jitterAmount, jitterAmount);
    }
}
