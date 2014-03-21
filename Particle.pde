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
    this.intensity = intensity;
    this.speed = speed;
    this.ignoreNode = ignoreNode;
    this.rnd = random(0.5, 1.5);
    this.col = col;
  }  
  
  public boolean update(){
    //intensity -= 1/frameRate;
    speed *= 0.999;
    intensity *= 0.99;
    position += speed;
   // dx = x;
   // dy = y;
    
    x = map (position, 0, 1, Global.points[startNode][0], Global.points[endNode][0]);
    y = map (position, 0, 1, Global.points[startNode][1], Global.points[endNode][1]);
    z = map (position, 0, 1, Global.points[startNode][4]/4, 500);
    
    //dx = x-dx;
   // dy = y-dy;
    
    if (position >= 1){
      generateSubParticles (endNode, intensity, speed, ignoreNode, col);
    }
     
    return intensity > 0.001 && position <1;
  }
  
  public void draw(){
    
    strokeWeight (intensity/10);
    stroke(col,100,100, intensity/2);
        
    point (x,y, 600);
   // println ("-- "+x+" "+y+" "+z);
  }
}

 public void generateSubParticles(int startNode, float intensity, float speed, int ignoreNode, float col){
    int [] links = Global.myDelaunay.getLinked(startNode);
    
    for (int ii=1; ii < links.length; ii++){
      if (ii != ignoreNode && links[ii] != 0){
        Global.particlesToAdd.add( new Particle ( startNode, links[ii], intensity / (links.length), speed / (links.length), -1, col));    
      }  
   }
}
