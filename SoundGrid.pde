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
int unterteilungen = 8;

int bandbreiteOld;
int unterteilungenOld;
int sqSize;
float sqlen;

Minim minim;
AudioPlayer input;
FFT fftReal;
Textlabel label;

ControlP5 cp5;

int sizeX = displayWidth;
int sizeY = displayHeight;

int num = 11;


float[][] myEdges;
int[][] myLinks;

float [] avgIntensity;
float [] avgIntensityOld;
 
float t = 0;
int secondsRun = 0;

PShader vertexShader;
int mode = 0;

float colorOverTime = 50;
float targetColor = 0;
float targetColorOld = 0;

float max;
int maxElement;
float [] maxElements;

boolean sketchFullScreen() {
  return true;
}

void setup(){
  Global.topLayer = createGraphics(displayWidth,displayHeight);
  sizeX = displayWidth;
  sizeY = displayHeight;
  size (sizeX, sizeY, OPENGL);
  cp5 = new ControlP5(this);
  minim = new Minim(this);
  
  input = minim.loadFile("data/test.mp3");
    
  float x = 20;
  float y = 20;
  float sliderSpace = 20;
  //cp5.addSlider("bandbreite").setPosition(x,y +=sliderSpace).setRange(10,5000);
  //cp5.addSlider("unterteilungen").setPosition(x,y +=sliderSpace).setRange(1,75);
  
  bandbreiteOld = bandbreite;
  unterteilungenOld = unterteilungen;
  //label = cp5.addTextlabel("label").setPosition(x,y +=sliderSpace).setFont(createFont("Arial",20));
   
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
  sqlen = Global.points.length - ((sqSize+2)*4);
  avgIntensity = new float[(int)sqlen];
  avgIntensityOld = new float[(int)sqlen];
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
        Global.points[i*sqSize+ii][0] = (sizeX/sqSize) * (i+0.5) + random (-5, 5);
        Global.points[i*sqSize+ii][1] = (sizeY/sqSize) * (ii+0.5) + random (-5, 5);
        
        Global.points[i*sqSize+ii][5] = Global.points[i*sqSize+ii][0];
        Global.points[i*sqSize+ii][6] = Global.points[i*sqSize+ii][1];
      }
    }
  }
 
 //Random
  if (mode == 1){
    for (int i = 0; i<sqSize*sqSize; i++){   
      Global.points[i][0] = random(0, sizeX);
      Global.points[i][1] = random(0, sizeY);   
      Global.points[i][5] = Global.points[i][0];
      Global.points[i][6] = Global.points[i][1];
    }
  }
  
  
  int arrsize = sqSize*sqSize;
  float step = sizeX / (sqSize);
  for (int i = 0; i<sqSize+2; i++){
    Global.points[arrsize+i*4+0][0] = step * i;
    Global.points[arrsize+i*4+0][1] = 0; 
    
    Global.points[arrsize+i*4+1][0] = step * i;
    Global.points[arrsize+i*4+1][1] = sizeY; 
    
    Global.points[arrsize+i*4+2][0] = 0;
    Global.points[arrsize+i*4+2][1] = step * i; 
    
    Global.points[arrsize+i*4+3][0] = sizeX;
    Global.points[arrsize+i*4+3][1] = step * i; 
  }
   
  fftReal.window(FFT.HAMMING);
  
  //vertices
  generateVertices();
}

void generateVertices(){  
  Global.myDelaunay = new Delaunay( Global.points );
  myLinks = Global.myDelaunay.getLinks(); 
  
  Global.vertices = new IntList();
  Global.links = Global.myDelaunay.getLinks();
  maxElements = new float [Global.points.length];
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
  maxElement = 0;
  max = 0;
  for(int i=0; i<Global.points.length; i++)
  {  
      float val = fftReal.getAvg(i);
     avg += val;
     if (val > max){
        max = val;
        maxElement = i; 
     }     
  }
  avg = avg / Global.points.length;
  maxElements[maxElement]++;
  
  if (frameCount % 100 == 0){
     float newMax = 0;
     float newMaxElement = 0;
     for(int i=0; i<Global.points.length; i++)
     {
        float val = maxElements[i];
        if (val > newMax){
           newMax = val;
           newMaxElement = i;
        }
     }
    
     targetColorOld = targetColor;
     targetColor = map (newMaxElement, Global.points.length*0, Global.points.length*1, 0, 100); 
     maxElements = new float[Global.points.length];
  } else {
     colorOverTime = map (frameCount % 100, 0,99, targetColorOld, targetColor);
  }
  
  if (bandbreiteOld != bandbreite ||  unterteilungenOld != unterteilungen){
    bandbreiteOld = bandbreite;
    unterteilungenOld = unterteilungen;
    renew(); 
  }
  
  colorMode(HSB, 100);
  background (0);   
  t += 1/frameRate; // /10;
  
  int secs = floor(t);
  if (secs != secondsRun){  
    secondsRun = secs;
  }
  
  pushMatrix();
    
  if (Global.mode == 1){
    pointLight(0,0,100, Global.fieldSize/4, Global.fieldSize/4, Global.fieldSize);  
    
    directionalLight(colorOverTime,100,100, 1,0,0.1);
    directionalLight(colorOverTime,100,100, -1,0,0.1);
    directionalLight(colorOverTime,100,100, 0,1,0.1);
    directionalLight(colorOverTime,100,100, 0,-1,0.1);
    
  } if (Global.mode == 2){ 
    
    pointLight(60,100,6, Global.fieldSize/4, Global.fieldSize/4, Global.fieldSize);  
    
    directionalLight(0,00,40, 1,0,-0.1);
    directionalLight(0,00,40, -1,0,-0.1);
    directionalLight(0,00,40, 0,1,-0.1);
    directionalLight(0,00,40, 0,-1,-0.1);
  } if (Global.mode == 3){ 
    pointLight(0,0,100, Global.fieldSize/4, Global.fieldSize/4, -Global.fieldSize);  
  } 
  
  fftReal.forward(input.left);  
  
  for(int i=1; i<sqlen; i++)
  { 
    int [] links = Global.myDelaunay.getLinked(i);
    float locX = Global.points[i][0];
    float locY = Global.points[i][1];          
        if (frameCount % 5 == 0){
           float delta = avgIntensity[i] - avgIntensityOld[i];
           delta = min (500, delta);
           if (Global.lineMode == 1 && delta > 20){
             generateParticles (i,  delta/3 , /*0.01*/ ( delta)  /5000  , (i / sqlen));
           } else if (Global.lineMode == 2 ){
             generateParticles (i,  delta/100  , /*0.01*/  (delta/10 ) /10000  , (i / sqlen)*2);
           } 
            avgIntensity[i] = avgIntensityOld[i]; 
            avgIntensity[i] = 0;
         }
    
    if ( (fftReal.getAvg(i))*5 > Global.points[i][4] && fftReal.getAvg(i) > avg * 0 ){
       Global.points[i][4] = (fftReal.getAvg(i))*5;
       avgIntensity[i] += (fftReal.getAvg(i));
    } else {
       Global.points[i][4] = Global.points[i][4] * 0.98;
    }
    
    Global.points[i][4] = constrain (Global.points[i][4], 0, sizeY/2);
    
    float locGrv = Global.points[i][4];
    fill ( Global.points[i][4] ,100, 100 );
    
    int grvX = 0;
    int grvY = 0;
    float maxDist = 5 * (sizeX / unterteilungenOld);
        
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
        vertex(Global.points[Global.vertices.get(i)][0], Global.points[Global.vertices.get(i)][1], Global.points[Global.vertices.get(i)][4]/4);    
        vertex(Global.points[Global.vertices.get(i+1)][0], Global.points[Global.vertices.get(i+1)][1], Global.points[Global.vertices.get(i+1)][4]/4);
        vertex(Global.points[Global.vertices.get(i+2)][0], Global.points[Global.vertices.get(i+2)][1], Global.points[Global.vertices.get(i+2)][4]/4);
    }  
    endShape(); 
  }
  
  if (Global.lineMode == 2) {
    stroke (0, 100,100);
    for (int i =0; i< Global.links.length; i++){
        int startPoint = Global.links[i][0];
        int endPoint = Global.links[i][1];
        float newCol = 0;
        if (Global.mode == 1){
          newCol = 0;
        } else if (Global.mode == 2){
          newCol = 30;
        }
        
        stroke(newCol,100, 100, max(5, Global.points[startPoint][4]/10));
        strokeWeight (1);
        line (Global.points[startPoint][0], Global.points[startPoint][1], 600, Global.points[endPoint][0], Global.points[endPoint][1], 600);
    }
  }
  
  if (Global.lineMode == 1){
  } else if (Global.lineMode == 2) {
    beginShape(LINES);
  }

  for (Iterator<Particle> particleIter = Global.particles.iterator(); particleIter.hasNext();){ 
      Particle particle = particleIter.next(); 
      if(!particle.update()){ 
        particleIter.remove(); 
      } else {
        particle.draw();
      }
   } 
   if (Global.lineMode == 1){
  } else if (Global.lineMode == 2) {
    endShape();
  }
   
   for (Iterator<Particle> particleIter = Global.particlesToAdd.iterator(); particleIter.hasNext();){ 
      Particle thisParticle = particleIter.next(); 
      Global.particles.add (thisParticle);
      particleIter.remove(); 
   } 
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
    Global.lineMode = 1;
  }
  
  if (key == 'r'){  // dunkel
    lock = true;
    Global.lineMode = 2;
    Global.particles = new ArrayList<Particle>();
    lock = false;
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
