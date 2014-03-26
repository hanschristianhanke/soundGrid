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
    float fps = 1/frameRate;
    if (Global.lineMode == 1){
      speed -= fps/50;
      intensity -= fps*10;
      position += speed;      
      x = map (position, 0, 1, Global.points[startNode][0], Global.points[endNode][0]);
      y = map (position, 0, 1, Global.points[startNode][1], Global.points[endNode][1]);
      z = map (position, 0, 1, Global.points[startNode][4]/4, 500);      
      if (position >= 1){
        generateSubParticles (endNode, intensity, speed, ignoreNode, col);
      }       
      return intensity > 0.2 && position <1;
    } else if (Global.lineMode == 2){
      speed -= fps/10;
      intensity -= fps*10;
      position = position + speed/100;      
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
    float newCol;
      if (Global.mode == 1){
        newCol = map (col, 0,1, 60,100); 
      } else {
        newCol = map (col, 0,1, 0,60);
      }
     
   if (Global.lineMode == 1){
      stroke(newCol,100, 100, 100*map(intensity, 0.1, 1, 0, 1)*(1-position) );//max(50, intensity*10));
      strokeWeight ( max (1,intensity/5)); 
     point (x,y, 600);
 } else if (Global.lineMode == 2){
      stroke(newCol,100, 100, 100*map(intensity, 0.1, 2, 0, 1)*(1-position));
      vertex(Global.points[startNode][0], Global.points[startNode][1], 600);
     stroke(newCol,100, 100, max(0, intensity));
      vertex(x,y,600);
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
