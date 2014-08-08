# Make scoring matrices

makeprobmat<-function(nndists,dotprods,distbreaks,dotprodbreaks=seq(0,1,by=0.1),ReturnCounts=TRUE){
  if(missing(distbreaks)) distbreaks=c(0,0.75,1.5,2,2.5,3,3.5,4,5,6,7,8,9,10,12,14,16,20,25,30,40,500)
  if(missing(dotprods)){
    if(is.list(nndists) && length(nndists[[1]])==2){
      dotprods=sapply(nndists,"[[",2)
      nndists=sapply(nndists,"[[",1)
    } else
      stop("dotprods missing and unable to parse nndists as combined list")
  }
  countmat=table(cut(unlist(nndists),br=distbreaks),
                 cut(unlist(dotprods),dotprodbreaks))
  attr(countmat,"distbreaks")=distbreaks
  attr(countmat,"dotprodbreaks")=dotprodbreaks
  if(!ReturnCounts) countmat/sum(countmat)
  else countmat
}

scorematrix<-function(matchmat='dl2match.probmat',randmat='mismatch.probmat',
                      logbase=2,fudgefac=1e-6,...){
  if(!exists(matchmat)) load(file.path(fcconfig$rootdir,"data",paste(matchmat,sep="",".rda")))
  matchmat=get(matchmat)
  distbreaks=attr(matchmat,"distbreaks")
  ndistbreaks=length(distbreaks)
  dotprodbreaks=attr(matchmat,"dotprodbreaks")
  ndpbins=length(dotprodbreaks)-1

  if(!exists(randmat)) load(file.path(fcconfig$rootdir,"data",paste(randmat,sep="",".rda")))
  randmat=get(randmat)
  if(!isTRUE(all.equal(dim(randmat),dim(matchmat))))
    stop("Mismatch between match and mismatch dimensions")
  if(!isTRUE(all.equal(
    distbreaks[-ndistbreaks],distbreaks[-ndistbreaks],check.attributes=F)))
    stop("mismatch between distance breaks used for match and null models")

  log((matchmat+fudgefac)/(randmat+fudgefac),logbase)
}
