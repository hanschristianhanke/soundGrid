import java.util.List;
import java.util.ArrayList;

 

class Pyramid {
  
 float beginX;
 float beginY; 
 float endX; 
 float endY;
 
 // a       b
 //
 //     e
 //
 // c       d
 
 
 Pyramid (float beginX, float beginY, float endX, float endY){
   this.beginX = beginX;
   this.beginY = beginY;
   this.endX = endX;
   this.endY = endY;
 }
 
 
  
 void draw(){
  float pyramidHeight = Global.fieldSize / pow(2, Global.recursion) ; //(endX - beginX)/2;
  
  float midX = map (0.5, 0, 1, beginX, endX);
  float midY = map (0.5, 0, 1, beginY, endY);
  
  float corGravX = Global.gravX + Global.fieldSize/2;
  float corGravY = Global.gravY + Global.fieldSize/2;
  
  PVector target = new PVector(corGravX - midX, corGravY - midY);
  target.normalize();
  //println (corGravX + "  "+midX+ "  "+target.x);
  
  float distance = dist(midX, midY, corGravX, corGravY);
 // println (distance);
  distance = 1- (distance / (Global.fieldSize/2));
  
  //target.mult(distance*100);
  target.mult(Global.fieldSize/2);
  //midX = map (min(1, max (0, distance)), 0, recursion/2, midX, corGravX);
  //midY = map (min(1, max (0, distance)), 0, recursion/2, midY, corGravY);
  //midX = map (0.5, 0, 1, beginX, endX) + target.x;
 // midY = map (0.5, 0, 1, beginY, endY) + target.y;
    
  float [] a = {beginX, Global.heightLevel, beginY};
  float [] b = {endX, Global.heightLevel, beginY};
  float [] c = {beginX, Global.heightLevel, endY};
  float [] d = {endX, Global.heightLevel, endY};
  float [] e = {midX , Global.heightLevel - pyramidHeight, midY};

  //stroke (255);
  //fill(255*distance, 100, 100);
  fill(255);
  beginShape(TRIANGLES);
  vertex(a[0], a[1], a[2]);
  vertex(b[0], b[1], b[2]);
  vertex(e[0], e[1], e[2]);

  vertex(a[0], a[1], a[2]);
  vertex(c[0], c[1], c[2]);
  vertex(e[0], e[1], e[2]);

  vertex(c[0], c[1], c[2]);
  vertex(d[0], d[1], d[2]);
  vertex(e[0], e[1], e[2]);

  vertex(d[0], d[1], d[2]);
  vertex(b[0], b[1], b[2]);
  vertex(e[0], e[1], e[2]);
  
  endShape(CLOSE);
 } 
}
