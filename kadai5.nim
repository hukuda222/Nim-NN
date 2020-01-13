import random
import sugar
import math
import strutils
import progress
import sequtils
import algorithm

randomize()

proc calc_E(x: seq[int], w: seq[seq[float]],cons: float): float =
  var E:float = 0
  for i1 in 0..16:
    for i2 in 0..16:
      E += w[i1][i2]*(x[i1]*x[i2]).float
  return -E/2+cons

proc softmax(a: float,b:float):tuple[a:float,b:float]=
  var aa:float= exp(-a)
  var bb:float= exp(-b)
  return (aa/(aa+bb),bb/(aa+bb))


proc transition(x:seq[int],w:seq[seq[float]],cons:float,alpha:float):seq[int]=
  var xi:int = rand(1..16)
  var x2:seq[int] = x
  x2[xi] = ((x[xi]+1)mod 2)

  if softmax(-alpha*calc_E(x,w,cons),-alpha*calc_E(x2,w,cons)).a>=rand(1.0):
    return x2
  else:
    return x


proc bit2int(x:seq[int]):int=
  var a:int = 0
  for i in 1..16:
    a += x[i]*(2^(16-i))
  return a

proc int2bit(x:int):seq[int]=
  var a:string = x.toBin(16)
  var x = lc[0 | (_ <- 0..16),int]
  x[0] = 1
  for i in 1..16:
    if a[i-1]=='1':
      x[i] = 1
  return x

proc calc_distribution(xs:seq[seq[int]],w:seq[seq[float]],cons:float,alpha:float):seq[float]=
  var exp_x:seq[float] = lc[exp(-alpha*calc_E(x,w,cons))|(x <- xs),float]
  var sum_x:float = exp_x.foldl(a+b)
  return lc[(ex/sum_x)*10000|(ex<-exp_x),float]
  #return lc[calc_E(x,w,cons)|(x <- xs),float]

var cons:float = 1.75
var alpha:float = 2
var beta:float = 1.3
var gamma:float=0.05#0.25#0.7
var x = lc[0 | (_ <- 0..16),int]
var ans = lc[0 | (_ <- 0..65535),int]
var w = lc[lc[0 | (_ <- 0..16),float]|(_<-0..16), seq[float]]

for i in 0..16:
  w[0][i]+=0.5*beta

for i in [1,5,9,13]:
  for j in 0..3:
    for k in 0..3:
      if j!=k:
        w[i+k][i+j] += -1*beta

for i in 1..4:
  for j in [0,4,8,12]:
    for k in [0,4,8,12]:
      if j!=k:
        w[i+j][i+k] += -1*beta


for i in [0,4,8,12]:
  w[1+i][1+((5+i)mod 16)]-=10.0*gamma #A->B
  w[1+i][1+((6+i)mod 16)]-=6.0*gamma #A->C
  w[1+i][1+((7+i)mod 16)]-=9.0*gamma #A->D
  w[2+i][1+((4+i)mod 16)]-=10.0*gamma #B->A
  w[2+i][1+((6+i)mod 16)]-=7.0*gamma #B->C
  w[2+i][1+((7+i)mod 16)]-=3.0*gamma #B->D
  w[3+i][1+((4+i)mod 16)]-=6.0*gamma #C->A
  w[3+i][1+((5+i)mod 16)]-=7.0*gamma #C->B
  w[3+i][1+((7+i)mod 16)]-=10.0*gamma #C->D
  w[4+i][1+((4+i)mod 16)]-=9.0*gamma #D->A
  w[4+i][1+((5+i)mod 16)]-=3.0*gamma #D->B
  w[4+i][1+((6+i)mod 16)]-=10.0*gamma #D->C

x[0] = 1
for i in 1..16:
    x[i]=rand(0..1)

for t in 1..100000:
  x=transition(x,w,cons,alpha)
  ans[bit2int(x)]+=1


#var dist:seq[float] = calc_distribution(lc[int2bit(i)|(i <- 0..65535),seq[int]],w,cons,alpha)
var ans_index:seq[tuple[occ:int,index:int]] = lc[(ans[i],i)|(i <- 0..65535),tuple[occ:int,index:int]]
var sorted_ans_index:seq[tuple[occ:int,index:int]] = sorted(ans_index, system.cmp[tuple[occ:int,index:int]], Descending)
for i in 0..9:
  echo sorted_ans_index[i].index.toBin(16)," & ",sorted_ans_index[i].occ,"\\\\"
#for i in 0..65535:
#  echo i.toBin(16),",",ans[i],",",dist[i].toInt
