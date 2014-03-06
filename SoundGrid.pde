import megamu.mesh.*;

import java.util.List;
import java.util.ArrayList;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.spi.*;

int bandbreite = 100;
int unterteilungen = 8;

int bandbreiteOld;
int unterteilungenOld;

Minim minim;
AudioPlayer input;
FFT fftReal;
Textlabel label;

ControlP5 cp5;

int size = 800;

int num = 11;
float [][] points;
IntList vertices = new IntList();

Delaunay myDelaunay;

float[][] myEdges;
int[][] myLinks;
 
float t = 0;
int secondsRun = 0;

PShader vertexShader;

void setup(){
  size (size, size, OPENGL);
  cp5 = new ControlP5(this);
  minim = new Minim(this);
  
  input = minim.loadFile("data/sounds of life - currents.mp3");
  

  
  float x = 20;
  float y = 20;
  float sliderSpace = 20;
  cp5.addSlider("bandbreite").setPosition(x,y +=sliderSpace).setRange(10,5000);
  cp5.addSlider("unterteilungen").setPosition(x,y +=sliderSpace).setRange(1,75);
  
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
 // myEdges = myDelaunay.getEdges();
   
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
  fftReal.logAverages(bandbreite, unterteilungen);
  background (0);   
  int sqSize = floor(sqrt(fftReal.avgSize())* 0.8);
  points = new float[(sqSize*sqSize)][5];
  /*
  0,1  Postion X/Y
  2,3  Directional Vector
  4    Gravity
  */
  
  //Grid 
  for (int i = 0; i<sqSize; i++){
    for (int ii = 0; ii<sqSize; ii++){
      points[i*sqSize+ii][0] = (size/sqSize) * (i+0.5) + random (-size/50, size/40);
      points[i*sqSize+ii][1] = (size/sqSize) * (ii+0.5) + random (-size/40, size/50);
      
      println("ps "+getPoisson(100));
      
      //points[i*sqSize+ii][2] = points[i*sqSize+ii][0];
      //points[i*sqSize+ii][3] = points[i*sqSize+ii][1];
    }
  }
  
  //Random
  /*for (int i = 0; i<sqSize*sqSize; i++){   
    points[i][0] = random(0, size);
    points[i][1] = random(0, size);      
  }*/
  
 
  fftReal.window(FFT.HAMMING);
  
  //vertices
  generateVertices();
}

void generateVertices(){  
  myDelaunay = new Delaunay( points );
  myLinks = myDelaunay.getLinks(); 
  vertices = new IntList();
  for(int i=0; i<points.length; i++)
  {
      if (true || points[i][4] > 7){
      int [] links = myDelaunay.getLinked(i);
      if (links.length == 2){
          if ( containsValue(myDelaunay.getLinked(links[0]), links[1]) && containsValue(myDelaunay.getLinked(links[1]), links[0])){
              vertices.append(i);
              vertices.append(links[0]);
              vertices.append(links[1]);
          }
      } else if (links.length > 2){
         for (int a=0; a<links.length; a++){
            int [] linksA = myDelaunay.getLinked(links[a]);
            for (int b=a+1; b<links.length; b++){              
              int [] linksB = myDelaunay.getLinked(links[b]); 
                 if (containsEachOther(links[a], linksA, links[b], linksB)){
                 //if (containsValue(linksA, b) && containsValue(linksB, a)){
                 
                   //println ("node "+i+" "+links[a]+"  "+links[b]);
                   vertices.append(i);
                   vertices.append(links[a]);
                   vertices.append(links[b]);
                  }
               }
            }
         }
      
  }
      }
}

void draw (){  
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
    generateVertices();
  }
  
  pushMatrix();
  //fill(0,5);
  //blendMode(BLEND);  
  //rect(0, 0, width, height);
  //fill(0,20);
  //blendMode(ADD);  
 
 // translate (Global.fieldSize/2, Global.fieldSize/2, 0); 
  pointLight(0,0,100, Global.fieldSize/4, Global.fieldSize/4, Global.fieldSize/2);  
  //directionalLight(126, 126, 126, Global.fieldSize/2 + Global.gravX, -Global.fieldSize, Global.fieldSize/2 + Global.gravY);
  //ambientLight(72, 72, 102);



  fftReal.forward(input.left);
  
   
  float max = 0;   
  for(int i=0; i<points.length; i++)
  {    
     float newV = fftReal.getAvg(i);
     if (newV > max){
       max = newV;
     }
  }
 // max = 100;
  
  
  stroke (0, 100, 0);
  fill ( 0,0, 100 );
  beginShape(TRIANGLES);  
  for (int i = 0; i<vertices.size(); i=i+3){    
      vertex(points[vertices.get(i)][0], points[vertices.get(i)][1], points[vertices.get(i)][4]);    
      vertex(points[vertices.get(i+1)][0], points[vertices.get(i+1)][1], points[vertices.get(i+1)][4]);
      vertex(points[vertices.get(i+2)][0], points[vertices.get(i+2)][1], points[vertices.get(i+2)][4]);
  }
  endShape();
  
 //noStroke();
 
  for(int i=0; i<points.length; i++)
  { 
    int [] links = myDelaunay.getLinked(i);
    float locX = points[i][0];
    float locY = points[i][1];
    float locGrv = points[i][4];
    
    if ( fftReal.getAvg(i) > points[i][4]){
      // points[i][4] += fftReal.getAvg(i)* 1/frameRate*30;
       points[i][4] += fftReal.getAvg(i)/max*10;
    } else {
       points[i][4] = points[i][4] * 0.95;
    }
    fill ( points[i][4] ,100, 100 );
    
    int grvX = 0;
    int grvY = 0;
    for (int ii=0; ii < links.length; ii++){
      float [] pnt = points[links[ii]];
      float diff = abs( 100 - (100/locGrv)* pnt[4]);
      float factor = 0;
      if (diff < 10){
        factor = 0.15;
      } else if (diff > 90){
        //factor = -0.07;
      }
      
      float distance = dist(locX, locY, pnt[0], pnt[1]);
      
      //factor *= lerp( distance, 0, 10)/10;
      
      grvX += (pnt[0] - locX) * (pnt[4] * locGrv)/10  / links.length * factor;
      grvY += (pnt[1] - locY) * (pnt[4] * locGrv)/10  / links.length * factor;
     
     }
    
    points[i][2] = grvX * 1/frameRate*0.01;
    points[i][3] = grvY * 1/frameRate*0.01;
    
    points[i][0] += points[i][2];
    points[i][1] += points[i][3];
    
    textSize(10);
    
    //points[i][0] = points[i][2] + random (-0.1, 0.1)*fftReal.getAvg(i);
    //points[i][1] = points[i][3] + random (-0.1, 0.1)*fftReal.getAvg(i);
    text("Frq "+fftReal.getAverageCenterFrequency(i), points[i][0]-5, points[i][1] -15); 
  //  ellipse(points[i][0], points[i][1], 15, 15);
    
    int count = 0;
    for(int ii=0; ii<myLinks.length; ii++)
    {
      int startIndex = myLinks[ii][0];
      
      if (startIndex == i){
          stroke ( 100,100, 100 );          
          int endIndex = myLinks[ii][1];
          
          float startX = points[startIndex][0];
          float startY = points[startIndex][1];
          float endX = points[endIndex][0]+5;
          float endY = points[endIndex][1]+5;
          //line( startX, startY, endX, endY );
          text("Cnt "+count, startX+ (endX-startX)/2, startY+ (endY-startY)/2); 
           count++;
      }
    }
  }
 
   
  //Lines per Links
   /*
  for(int i=0; i<myLinks.length; i++)
  {
    int startIndex = myLinks[i][0];
    stroke ( 100,100, 100 );
    int endIndex = myLinks[i][1];
    
   // points[startIndex][0] = random (-0.5,0.5);
   // points[startIndex][1] += random (-0.5,0.5);
   
    float startX = points[startIndex][0];
    float startY = points[startIndex][1];
    float endX = points[endIndex][0]+5;
    float endY = points[endIndex][1]+5;
    beginShape(TRIANGLES);
    line( startX, startY, endX, endY );
    endShape(CLOSE);
  }
  */
  
 

   // stroke (255,0,0);
  // line (0, 0, 1, 10, 0, 1);
     
  //    translate (Global.fieldSize/2 + Global.gravX, -Global.fieldSize / pow (2, Global.recursion), Global.fieldSize/2 + Global.gravY); 
    // sphere (10);  
  popMatrix();
 
}

void pyramidSquare (float beginX, float beginY, float endX, float endY, int recursion){
 
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
  if (key == ' '){
    background (0);
  }
}
