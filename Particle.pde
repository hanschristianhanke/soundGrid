class Particle {
  
  int startNode;
  int endNode;
  float intensity;
  float speed;
  int ignoreNode;
  
  float position = 0;
  float x = 0;
  float y = 0;  
  float z = 0;  
  
  float dx = 0;
  float dy = 0;
  
  Particle (int startNode, int endNode, float intensity, float speed, int ignoreNode){
    this.startNode = startNode;
    this.endNode = endNode;
    this.intensity = intensity;
    this.speed = speed;
    this.ignoreNode = ignoreNode;
  }  
  
  public boolean update(){
    //intensity -= 1/frameRate;
    speed *= 0.95;
    intensity *= 0.95;
    position += speed;
    dx = x;
    dy = y;
    
    x = map (position, 0, 1, Global.points[startNode][0], Global.points[endNode][0]);
    y = map (position, 0, 1, Global.points[startNode][1], Global.points[endNode][1]);
    z = map (position, 0, 1, Global.points[startNode][4]/4, 50);
    
    dx = x-dx;
    dy = y-dy;
    
    if (position >= 1){
      generateSubParticles (endNode, intensity, speed, ignoreNode);
    }
     
    return speed > 0.001 && position <1;
  }
  
  public void draw(){
    strokeWeight (5);
    stroke(255,0,0, intensity);
        
    point (x+sin(intensity)*dy*1,y+cos(intensity)*dx*1,z);
   // println ("-- "+x+" "+y+" "+z);
  }
}

 public void generateSubParticles(int startNode, float intensity, float speed, int ignoreNode){
    int [] links = Global.myDelaunay.getLinked(startNode);
    
    for (int ii=1; ii < links.length; ii++){
      if (ii != ignoreNode && links[ii] != 0){
        Global.particlesToAdd.add( new Particle ( startNode, links[ii], intensity, speed, -1));    
      }  
   }
}
