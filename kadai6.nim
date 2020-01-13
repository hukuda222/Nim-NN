import random
import sugar
import math


randomize()

proc calc_E(x: seq[int], w: seq[seq[float]]): float =
  var E:float = 0
  for i1 in 0..6:
    for i2 in 0..6:
      E += w[i1][i2]*(x[i1]*x[i2]).float
  return -E/2

proc softmax(a: float,b:float):tuple[a:float,b:float]=
  var aa:float= exp(-a)
  var bb:float= exp(-b)
  return (aa/(aa+bb),bb/(aa+bb))


proc transition(x:seq[int],w:seq[seq[float]],alpha:float,phase:int):seq[int]=
  var m = 6
  if phase == 2:
    m=5
  var xi:int = rand(3..m)
  var x2:seq[int] = x
  x2[xi] = ((x[xi]+1)mod 2)

  if softmax(-alpha*calc_E(x,w),-alpha*calc_E(x2,w)).a>=rand(1.0):
    return x2
  else:
    return x


proc update_w(eps:float,w:seq[seq[float]],x1:seq[seq[float]],x2:seq[seq[float]]):seq[seq[float]]=
  var new_w=w
  # W_{xh}
  for i in 0..2:
    for j in 3..5:
      new_w[i][j] += eps*((x2[i][j])-(x1[i][j])).float
      new_w[j][i] += eps*((x2[i][j])-(x1[i][j])).float
  # W_{hy}
  for i in 3..5:
    new_w[i][6] += eps*((x2[i][6])-(x1[i][6])).float
    new_w[6][i] += eps*((x2[i][6])-(x1[i][6])).float
  # W_{x0y}
  new_w[0][6] += eps*((x2[0][6])-(x1[0][6])).float
  new_w[6][0] += eps*((x2[0][6])-(x1[0][6])).float
  return new_w

proc calc_ans(x:seq[int],w:seq[seq[float]]):float=
  var ans:float=0
  var hs:array[3,float]=[0.0,0.0,0.0]
  for i in 0..2:
    for j in 0..2:
      hs[j] += x[i].float*w[i][j+3]
  for i in 0..2:
    for j in 0..2:
      ans += hs[i].float*w[i+3][6]
  ans += x[0].float*w[0][6]
  return ans

var alpha:float = 3
var x = lc[0 | (_ <- 0..6),int]
var w = lc[lc[0 | (_ <- 0..6),float]|(_<-0..6), seq[float]]
var eps:float = 0.001
var T=10000


var data_index:array[4,tuple[x1:int,x2:int,y0:float,y1:float]]
  =[(0,0,0.8,0.2),(0,1,0.1,0.9),(1,0,0.3,0.7),(1,1,0.6,0.4)]

#var data_index:array[4,tuple[x1:int,x2:int,y0:float,y1:float]]
#  =[(0,0,1.0,0.0),(0,1,0.0,1.0),(1,0,0.0,1.0),(1,1,1.0,0.0)]

for data in data_index:
  var ans:array[2,int] = [0,0]
  for p in 1..100:
    for i in 0..6:
      for j in (i+1)..6:
        if (i>0 and i<=2) and j==6:
          continue
        elif i<=2 and j<=2:
          continue
        elif i>2 and i<=5 and j>2 and j<=5:
          continue
        w[i][j] = rand(2.0)-1.0
        w[j][i] = w[i][j]
    x[0] = 1
    x[1] = data.x1
    x[2] = data.x2
    for i in 3..6:
      x[i]=rand(0..1)
    var x2 = x
    for k in 1..10000:
      var avg_x1 = lc[lc[0 | (_ <- 0..6),float]|(_<-0..6), seq[float]]
      var avg_x2 = lc[lc[0 | (_ <- 0..6),float]|(_<-0..6), seq[float]]
      x = x2
      for t in 1..T:
        x=transition(x,w,alpha,1)
        for j in 0..6:
          for l in 0..6:
            avg_x1[j][l] += x[j].float*x[l].float
      for j in 0..6:
        for l in 0..6:
          avg_x1[j][l] /= T.float
      x2 = x
      if rand(1.0)<=data.y0:
        x2[6]=0
      else:
        x2[6]=1
      for t in 1..T:
        x2=transition(x2,w,alpha,2)
        for j in 0..6:
          for l in 0..6:
            avg_x2[j][l] += x2[j].float*x2[l].float
      for j in 0..6:
        for l in 0..6:
          avg_x2[j][l] /= T.float
      w = update_w(eps,w,avg_x1,avg_x2)
    if calc_ans(x,w)>0.5:
      ans[1]+=1
    else:
      ans[0]+=1
  echo "x : ",data.x1," , ",data.x2
  echo ans
  echo "-------------"


