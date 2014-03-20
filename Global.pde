static class Global {  
  static public List<Pyramid> pyramidList;
  static public int heightLevel = 0;
  static public int recursion = 0;
  static public int fieldSize = 2000;
  static public float gravX = 0;
  static public float gravY = 0;
  static public float zoomFactor = 1;
  
  static public int mainEmitterX = 0;
  static public int mainEmitterY = 0;
  static public int mainEmitterZ = 0;
  static public float escapeVelocity = 5;
  
  static public float [][] points;
  static public IntList vertices = new IntList();
  
  static public List<Particle> particles = new ArrayList<Particle>();
  static public List<Particle> particlesToAdd = new ArrayList<Particle>(); 
  
  static public Delaunay myDelaunay;
  
  
}
