library(jsonlite)
getversion<-function(){
vdf<-read.csv(paste0(Sys.getenv("GIT_RAW"),"/idsL/main/docs/versiontable.csv"))
#vdf<-read.csv(paste0(Sys.getenv("GIT_TOP"),"/idsL/docs/versiontable.csv"))
lv<-vdf[length(vdf$latestVersion),]
 mode(lv[1,])<-"character"
print(lv)

vjs<-toJSON(lv)
print(vjs)
# return(list(vjs))
# vjs
return(as.list(lv))
}
              

# getversion()
