class Particle {
  
  int startNode;
  int endNode;
  float intensity;
  float speed;
  int ignoreNode;
  float col;
  
  float position = 0;
  float x = 0;
  float y = 0;  
  float z = 0;  
  
  float dx = 0;
  float dy = 0;
  
  float rnd;
  
  Particle (int startNode, int endNode, float intensity, float speed, int ignoreNode, float col){
    this.startNode = startNode;
    this.endNode = endNode;
    this.intensity = min ( 40, intensity)+random(-4,4);
    this.speed = speed;
    this.ignoreNode = ignoreNode;
    this.rnd = random(0.5, 1.5);
    this.col = col;
  }  
  
  public boolean update(){
    
    if (Global.lineMode == 1){
      //intensity -= 1/frameRate;
      float fps = 1/frameRate;
      //speed *= 0.999;
      speed -= fps/25;
      intensity -= fps*10;
      //intensity *= 0.98*30*fps;
      position += speed;      
      x = map (position, 0, 1, Global.points[startNode][0], Global.points[endNode][0]);
      y = map (position, 0, 1, Global.points[startNode][1], Global.points[endNode][1]);
      z = map (position, 0, 1, Global.points[startNode][4]/4, 500);      
      if (position >= 1){
        generateSubParticles (endNode, intensity, speed, ignoreNode, col);
      }       
      return intensity > 0.2 && position <1;
    } else if (Global.lineMode == 2){
      //intensity -= 1/frameRate;
      speed *= 0.999;
      intensity *= 0.99;
      position += speed*30;      
      x = map (position, 0, 1, Global.points[startNode][0], Global.points[endNode][0]);
      y = map (position, 0, 1, Global.points[startNode][1], Global.points[endNode][1]);
      z = map (position, 0, 1, Global.points[startNode][4]/4, 500);      
      if (position >= 1){
        generateSubParticles (endNode, intensity, speed, ignoreNode, col);
      }       
      return intensity > 0.1 && position <1;
    }
    return false;
  }
  
  public void draw(){
    
   if (Global.lineMode == 1){
     // strokeWeight (intensity);
     float newCol;
      if (Global.mode == 1){
        newCol = map (col, 0,1, 60,100); 
      } else {
        newCol = map (col, 0,1, 0,60);
      }
     
      stroke(newCol,100, 100, 100*map(intensity, 0.1, 1, 0, 1)*(1-position) );//max(50, intensity*10));
      strokeWeight ( max (1,intensity/10));
     // stroke(col,100,100);      
     point (x,y, 600);
   //vertex(x,y,600);
 
 } else if (Global.lineMode == 2){
     float newCol;
      if (Global.mode == 1){
        newCol = map (col, 0,1, 60,100); 
      } else {
        newCol = map (col, 0,1, 0,60);
      }
     
     //beginShape(LINES);
     //strokeWeight (1);
      stroke(newCol,100, 100, 100*map(intensity, 0.1, 1, 0, 1)*(1-position));
      vertex(Global.points[startNode][0], Global.points[startNode][1], 600);
     stroke(newCol,100, 100, max(5, intensity));
      vertex(x,y,600);
 
      //stroke(newCol,100, 100, max(5, intensity*5));
      
     // stroke(col,100,100);   
      
      
     //line (Global.points[startNode][0], Global.points[startNode][1], 600, x,y,600);
     
    // endShape();
   }
    
    
  }
}

 public void generateSubParticles(int startNode, float intensity, float speed, int ignoreNode, float col){
    int [] links = Global.myDelaunay.getLinked(startNode);
    
    for (int ii=1; ii < links.length; ii++){
      if (ii != ignoreNode && links[ii] != 0){
        Global.particlesToAdd.add( new Particle ( startNode, links[ii], intensity/4 , speed , -1, col));    
      }  
   }
}
