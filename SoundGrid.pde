import megamu.mesh.*;

import java.util.List;
import java.util.ArrayList;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.spi.*;
import java.util.Iterator;

String [] songs = new String[]{ "12 Morning Breaks", "CraveYou", "moonbootica", "Super Flu & Andhim - Reeves (Original mix)(720p_H.264-AAC)"};
int actualSong = 0;

boolean lock = false;

int bandbreite = 50;
int unterteilungen = 6;

int bandbreiteOld;
int unterteilungenOld;
int sqSize;
Minim minim;
AudioPlayer input;
FFT fftReal;
Textlabel label;

ControlP5 cp5;

int size = 800;

int num = 11;




float[][] myEdges;
int[][] myLinks;
 
float t = 0;
int secondsRun = 0;

PShader vertexShader;
int mode = 0;

void setup(){
  Global.topLayer = createGraphics(size,size);
  
  size (size, size, OPENGL);
  cp5 = new ControlP5(this);
  minim = new Minim(this);
  
  input = minim.loadFile("data/044. Ray Charles - Georgia On My Mind (1960).mp3");
  

  
  float x = 20;
  float y = 20;
  float sliderSpace = 20;
  //cp5.addSlider("bandbreite").setPosition(x,y +=sliderSpace).setRange(10,5000);
  //cp5.addSlider("unterteilungen").setPosition(x,y +=sliderSpace).setRange(1,75);
  
  bandbreiteOld = bandbreite;
  unterteilungenOld = unterteilungen;
  //label = cp5.addTextlabel("label").setPosition(x,y +=sliderSpace).setFont(createFont("Arial",20));

 
/*  
  points[0][0] = 0;
  points[0][1] = 0;
  
  points[1][0] = size;
  points[1][1] = 0;
  
  points[2][0] = 0;
  points[2][1] = size;
  
  points[3][0] = size;
  points[3][1] = size;
  */
  Global.fieldSize = size;
  
  
 // smooth();
  
  //blendMode(ADD);  
  //colorMode(HSB);
 // myEdges = Global.myDelaunay.getEdges();
   
   input.play();
   input.loop();
  fftReal = new FFT( input.bufferSize(), input.sampleRate () );
  renew ();
  ortho();
  
  
}



boolean containsValue (int [] array, int value){
   for  (int i = 0; i< array.length; i++){
     if (array[i] == value){
        return true; 
     }
   }
   return false;
}

boolean containsEachOther (int a, int [] arrayA, int b, int [] arrayB){
  if (a==0 || b == 0){
    return false; 
  }
  for  (int i = 0; i< arrayA.length; i++){
     for  (int ii = 0; ii< arrayB.length; ii++){
       //println ("i = "+i+" ii = "+ii+" a = "+a+" b = "+b+" arrayA[i] "+arrayA[i]+" arrayB[ii] "+arrayB[ii] ); 
        if (arrayA[i] == b && arrayB[ii] == a){
           return true; 
        }
     }
   }
   return false;
}

void renew(){
  fftReal.logAverages(bandbreite, unterteilungenOld);
  background (0);   
  sqSize = floor(sqrt(fftReal.avgSize())* 0.8);
  Global.points = new float[(sqSize*sqSize) + (sqSize+2)*4][7];
  /*
  0,1  act. Postion X/Y
  2,3  dir. Vector
  4    Gravity
  5,6  org. Position X/Y
  */
  
  //Grid 
  if (mode == 0){
    for (int i = 0; i<sqSize; i++){
      for (int ii = 0; ii<sqSize; ii++){
        Global.points[i*sqSize+ii][0] = (size/sqSize) * (i+0.5) + random (-5, 5);
        Global.points[i*sqSize+ii][1] = (size/sqSize) * (ii+0.5) + random (-5, 5);
       // println (Global.points[i*sqSize+ii][0]+ " // "+Global.points[i*sqSize+ii][1]);
        
        Global.points[i*sqSize+ii][5] = Global.points[i*sqSize+ii][0];
        Global.points[i*sqSize+ii][6] = Global.points[i*sqSize+ii][1];
      }
    }
  }
 
 //Random
  if (mode == 1){
    for (int i = 0; i<sqSize*sqSize; i++){   
      Global.points[i][0] = random(0, size);
      Global.points[i][1] = random(0, size);   
      Global.points[i][5] = Global.points[i][0];
      Global.points[i][6] = Global.points[i][1];
    }
  }
  
  int arrsize = sqSize*sqSize;
  float step = size / (sqSize);
  for (int i = 0; i<sqSize+2; i++){
    Global.points[arrsize+i*4+0][0] = step * i;
    Global.points[arrsize+i*4+0][1] = 0; 
    
    Global.points[arrsize+i*4+1][0] = step * i;
    Global.points[arrsize+i*4+1][1] = size; 
    
    Global.points[arrsize+i*4+2][0] = 0;
    Global.points[arrsize+i*4+2][1] = step * i; 
    
    Global.points[arrsize+i*4+3][0] = size;
    Global.points[arrsize+i*4+3][1] = step * i; 
  }
  
  
  
  //SPIRALE
  /*
  for (int i = 0; i<sqSize*sqSize; i++){   
    Global.points[i][0] = cos(i)*i*5 + size/2 + random (-25, 25);;
    Global.points[i][1] = sin(i)*i*5 + size/2 + random (-25, 25);;
        
    Global.points[i][5] = Global.points[i][0];
    Global.points[i][6] = Global.points[i][1];
  }*/
 
  fftReal.window(FFT.HAMMING);
  
  //vertices
  generateVertices();
}

void generateVertices(){  
  Global.myDelaunay = new Delaunay( Global.points );
  myLinks = Global.myDelaunay.getLinks(); 
  Global.vertices = new IntList();
  for(int i=0; i<Global.points.length; i++)
  {
      int [] links = Global.myDelaunay.getLinked(i);
      if (links.length == 2){
          if ( containsValue(Global.myDelaunay.getLinked(links[0]), links[1]) && containsValue(Global.myDelaunay.getLinked(links[1]), links[0])){
              Global.vertices.append(i);
              Global.vertices.append(links[0]);
              Global.vertices.append(links[1]);
          }
      } else if (links.length > 2){
         for (int a=0; a<links.length; a++){
            int [] linksA = Global.myDelaunay.getLinked(links[a]);
            for (int b=a+1; b<links.length; b++){              
              int [] linksB = Global.myDelaunay.getLinked(links[b]); 
                 if (containsEachOther(links[a], linksA, links[b], linksB)){
                 //if (containsValue(linksA, b) && containsValue(linksB, a)){
                 
                   //println ("node "+i+" "+links[a]+"  "+links[b]);
                   Global.vertices.append(i);
                   Global.vertices.append(links[a]);
                   Global.vertices.append(links[b]);
                  }
               }
            }
         }
     }
}

void draw (){  
  if (!lock){
  float avg = 0;   
  for(int i=0; i<Global.points.length; i++)
  {    
     avg += fftReal.getAvg(i);
  }
  avg = avg / Global.points.length;
  
  
  //println (avg);
  //unterteilungen = floor( constrain( avg, 6, 32));
  if (bandbreiteOld != bandbreite ||  unterteilungenOld != unterteilungen){
    bandbreiteOld = bandbreite;
    unterteilungenOld = unterteilungen;
    renew(); 
  }
  
  colorMode(HSB, 100);
  //background (0);   
  t += 1/frameRate; // /10;
  
  int secs = floor(t);
  if (secs != secondsRun){  
    secondsRun = secs;
    //generateVertices();
  }
  
  pushMatrix();
  //fill(0,5);
  //blendMode(BLEND);  
  //rect(0, 0, width, height);
  //fill(0,20);
  //blendMode(ADD);  
 
 // translate (Global.fieldSize/2, Global.fieldSize/2, 0)
  
  if (Global.mode == 1){
    pointLight(0,0,100, Global.fieldSize/4, Global.fieldSize/4, Global.fieldSize);  
  } if (Global.mode == 2){ 
    directionalLight(0,10,40, 1,0,-0.1);
    directionalLight(0,10,40, -1,0,-0.1);
    directionalLight(0,10,40, 0,1,-0.1);
    directionalLight(0,10,40, 0,-1,-0.1);
  } if (Global.mode == 3){ 
    pointLight(0,0,100, Global.fieldSize/4, Global.fieldSize/4, -Global.fieldSize);  
  } 
  
  //ambientLight(72, 72, 102);



  fftReal.forward(input.left);
  
  float sqlen = Global.points.length - ((sqSize+2)*4);
  
  for(int i=1; i<sqlen; i++)
  { 
    int [] links = Global.myDelaunay.getLinked(i);
    float locX = Global.points[i][0];
    float locY = Global.points[i][1];   
    
    if ( (fftReal.getAvg(i))*5 > Global.points[i][4] && fftReal.getAvg(i) > avg * 0 ){
       Global.points[i][4] = (fftReal.getAvg(i))*5;
       //if (fftReal.getAvg(i) > avg*random (10,15)){
         //println (fftReal.getAvg(i) / avg);
         if (frameCount % 5 ==0){
         generateParticles (i, fftReal.getAvg(i), /*0.01*/ fftReal.getAvg(i)/5000  , (i / sqlen));
         }
       //}
    } else {
       Global.points[i][4] = Global.points[i][4] * 0.98;
    }
    
    Global.points[i][4] = constrain (Global.points[i][4], 0, size/2);
    
    float locGrv = Global.points[i][4];
    fill ( Global.points[i][4] ,100, 100 );
    
    int grvX = 0;
    int grvY = 0;
    float maxDist = 5 * (size / unterteilungenOld);
        
    for (int ii=1; ii < links.length; ii++){
      float [] pnt = Global.points[links[ii]];
      float factor = 0;
     
      float distance = dist(locX, locY, pnt[0], pnt[1]);
      float gravity = pow(map (constrain (distance, 0, maxDist), 0, maxDist, 1, 0),2);
      
      grvX += ((pnt[0] - locX) * pnt[4]  * gravity)/links.length * Global.relation; //*3.5;
      grvY += ((pnt[1] - locY) * pnt[4]  * gravity)/links.length * Global.relation; //*3.5;       
 
          
    }
    
    float distance = dist(locX, locY, Global.points[i][5], Global.points[i][6]);
    float gravity = pow(map (constrain (distance, 0, maxDist), 0, maxDist, 1, 0),2);
    //println (grvX);
    grvX += -(Global.points[i][0] - Global.points[i][5])*avg * (28.5-Global.relation); //; //*25;
    grvY += -(Global.points[i][1] - Global.points[i][6])*avg * (28.5-Global.relation); //*25;  
      
    Global.points[i][2] = grvX * 1/frameRate*Global.speed; //0.01;
    Global.points[i][3] = grvY * 1/frameRate*Global.speed; //0.01;
    
    Global.points[i][0] += Global.points[i][2];
    Global.points[i][1] += Global.points[i][3];
  }
 
  if (Global.mode != 3){
    beginShape(TRIANGLES); 
    noStroke(); 
    fill (0, 0, 100);
    for (int i = 0; i<Global.vertices.size(); i=i+3){    
       // fill ( 75, (Global.points[Global.vertices.get(i+0)][4]+Global.points[Global.vertices.get(i+1)][4]+Global.points[Global.vertices.get(i+2)][4])/10, 100 );
        vertex(Global.points[Global.vertices.get(i)][0], Global.points[Global.vertices.get(i)][1], Global.points[Global.vertices.get(i)][4]/4);    
        vertex(Global.points[Global.vertices.get(i+1)][0], Global.points[Global.vertices.get(i+1)][1], Global.points[Global.vertices.get(i+1)][4]/4);
        vertex(Global.points[Global.vertices.get(i+2)][0], Global.points[Global.vertices.get(i+2)][1], Global.points[Global.vertices.get(i+2)][4]/4);
    }  
    endShape(); 
  } else {
    stroke (0, 100,100);
    /*for (int i =0; i< Global.point.length; i++){
      int [] links = Global.myDelaunay.getLinked(i);
      for (int ii=0; ii<links.length; ii++){
      }
    }*/
  }
  
 /*beginShape(); 
 
     // fill ( 75, (Global.points[Global.vertices.get(i+0)][4]+Global.points[Global.vertices.get(i+1)][4]+Global.points[Global.vertices.get(i+2)][4])/10, 100 );
     texture (Global.topLayer);
     vertex(0, 0, 600, 0,   0);
     vertex( size, 0, 600, size, 0);
     vertex( size,  size, 600, size, size);
     vertex(0,  size, 600, 0,   size);
     
  endShape(); 
  */
  /*
  List <Particle> particlesToDelete = new ArrayList<Particle>();
  for (Particle particle : Global.particles){
    if (particle.update()!){
        particlesToDelete.add(particle);
    }
  }*/
  
//Global.topLayer.beginDraw();
//Global.topLayer.fill(1,5);
//Global.topLayer.blendMode(BLEND);  
//Global.topLayer.rect(0, 0, size, size);
//Global.topLayer.fill(0,20);
//Global.topLayer.blendMode(ADD); 

  for (Iterator<Particle> particleIter = Global.particles.iterator(); particleIter.hasNext();){ 
      Particle particle = particleIter.next(); 
      if(!particle.update()){ 
        particleIter.remove(); 
        //System.out.println("Paul wurde während der Iteration aus der Liste gelöscht!"); 
      } else {
        particle.draw();
      }
   } 
//Global.topLayer.endDraw();
   for (Iterator<Particle> particleIter = Global.particlesToAdd.iterator(); particleIter.hasNext();){ 
      Particle thisParticle = particleIter.next(); 
      Global.particles.add (thisParticle);
      particleIter.remove(); 
   } 
 // image (Global.topLayer, 0,0, 500);
 //println (Global.particles.size());
 
  popMatrix();
  }
}

int getPoisson(double lambda) {
  double L = Math.exp(-lambda);
  double p = 1.0;
  int k = 0;

  do {
    k++;
    p *= Math.random();
  } while (p > L);

  return k - 1;
}

void keyPressed() { 
  if (key == 'q'){         // dell
    Global.mode = 1;
  } 
 
  if (key == 'w'){  // dunkel
    Global.mode = 2;
  }
  
  if (key == 'e'){  // dunkel
    Global.mode = 3;
  }
  
   if (key == '1'){  // mode 0
    lock = true;
    mode = 0;
    renew();
    lock = false;
  }
  
   if (key == '2'){  // mode 1
    lock = true;
    mode = 1;
    renew();
    lock = false;
  }
  
  if (key == ',' && Global.relation > 0){  // mode 0
      Global.relation -= 0.1;
  }
  
  if (key == '.' && Global.relation < 28.5){  // mode 1
    Global.relation += 0.1;
  }
  
  if (key == 'o' && Global.speed > 0){  // mode 0
      Global.relation -= 0.001;
  }
  
  if (key == 'p' && Global.speed < 1){  // mode 1
    Global.relation += 0.001;
  }
  
  if (key == 'm'){
    input.pause();
    actualSong++;
    actualSong = actualSong%songs.length;
    println ("sn "+actualSong);
    input = minim.loadFile(songs[actualSong]+".mp3");
    input.play();
  }
  
}

public void generateParticles(int startNode, float intensity, float speed, float col){
    int [] links = Global.myDelaunay.getLinked(startNode);
    for (int ii=1; ii < links.length; ii++){
      if (links[ii] != 0){
        Global.particles.add( new Particle ( startNode, links[ii], intensity, speed, -1, col));
      }      
    }
}
