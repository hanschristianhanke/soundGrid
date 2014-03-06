class SoundNode {
  float directionX;
  float directionY;
  float speed;
  SoundNode (float direction, float speed){
    directionX = sin (direction);
    directionY = cos (direction);
  }  
  
  public void update(){
    
  }
}
