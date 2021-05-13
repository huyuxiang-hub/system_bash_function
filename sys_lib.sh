#!/bin/bash

function rm(){
  
    local suffix=$( date "+%Y-%m-%d-%H:%M:%S" ) 
    local File=$1
    local file

    for file in $File
    do

    if [ -d /scratchfs/juno/huyuxiang/Trash ] 
    then
         echo "/scratchfs/juno/huyuxiang/Trash exist."
    else 
        mkdir /scratchfs/juno/huyuxiang/Trash
      
    fi
    
   
    if [ -f $file ]
    then
         mv $file   /scratchfs/juno/huyuxiang/Trash/${file}-${suffix}
    fi
    
    if [ -d $file ]
    then
         mkdir /scratchfs/juno/huyuxiang/Trash/${file}-${suffix}
         mv ${file}/   /scratchfs/juno/huyuxiang/Trash/${file}-${suffix}/
    fi  
    echo "delete $file sucessfully!! you can recover it at /scratchfs/juno/huyuxiang/Trash/ !!"
    done

}

 
 function create_alg(){
  
   local alg_name=$1
   local cur_dir=$( pwd )
   echo "$alg_name"
     
   cp /junofs/users/huyuxiang/juno_centos7_v2/offline/Examples/FirstAlg $cur_dir/${alg_name} -r
   
   cd $cur_dir/${alg_name}/cmt
   sed "s/FirstAlg/${alg_name}/g"  requirements > requirements_tmp
   rm requirements
   mv requirements_tmp requirements

   cd $cur_dir/${alg_name}/python
   cp ./FirstAlg  ./${alg_name}  -r
   rm FirstAlg
  
   cd $cur_dir/${alg_name}/python/${alg_name}
   sed "s/FirstAlg/${alg_name}/g" __init__.py > __init__.py_tmp
   rm __init__.py
   mv __init__.py_tmp  __init__.py
  
   cd $cur_dir/${alg_name}/share/
   sed "s/FirstAlg/${alg_name}/g ; s/task.asTop()/ /g ; s/Sniper.Task/Sniper.TopTask/g" run.py > run.py_tmp
   rm run.py
   mv run.py_tmp run.py
   
   cd $cur_dir/${alg_name}/src/
   sed "s/FirstAlg/${alg_name}/g"  FirstAlg.cc > ${alg_name}.cc
   sed "s/FirstAlg/${alg_name}/g ; s/FIST_ALG/${alg_name}/g" FirstAlg.h > ${alg_name}.h
   rm FirstAlg.cc
   rm FirstAlg.h
  

   cd $cur_dir/${alg_name}/cmt
   cmt make clean
   cmt config
   cmt make
   
   cd $cur_dir/${alg_name}/share/
   python run.py
   
   cd $cur_dir/
   echo "${alg_name} is created successfully!!"



}

function data_ana(){

 local file=$1
 
 col=$( head -n1 $file | awk   -F  ' '  '{print NF}' )
  
 awk -v num=$col 'BEGIN{ for(i=1;i<=num;i++){sum[i]=0;ave[i]=0;} total=0;} {for(i=1;i<=num;i++){ sum[i]+=$i;} total+=1} END{for(i=1;i<=num;i++){ave[i]=sum[i]/total;print "the "i" columns: Sum      average   \n" "           "sum[i] "   " ave[i]"  \n" ;}}' $file
 
}

function print_file_num(){

cur_dir=`pwd`
file=$(ls -l | grep "^d" | awk '{print $9}')

for i in $( echo $file)
do
  echo -n "$i  "
  num=$( find ${cur_dir}/$i -type f | wc -l )
  echo $num
done

}

function cmt-make(){
   
   cmt make clean
   cmt config
   source setup.sh  
   cmt make   
}
function tds-cmd(){

  echo "this is version 1:  gamma : python $TUTORIALROOT/share/tut_detsim.py  --evtmax 10 gun --positions 0 0 0 --particles gamma  --momentums 1.0 --directions 1 0 0"
  echo "this is version 2:  protondecay : python $TUTORIALROOT/share/tut_detsim.py --evtmax 10  gun --particles e+ pi0 --momentums 400 400 --positions 0 0 0 0 0 0 --directions 1 0 0 -1 0 0 "
  echo "this is version 3: ibd :python $TUTORIALROOT/share/tut_detsim.py --evtmax 10 hepevt --exe IBD --volume pTarget --material LS "
}

function gamma(){
  python $TUTORIALROOT/share/tut_detsim.py  --evtmax 10 gun --positions 0 0 0 --particles gamma  --momentums 1.0 --directions 1 0 0
}

function protondecay(){
  python $TUTORIALROOT/share/tut_detsim.py --evtmax 1  gun --particles e+ pi0 --momentums 400 400 --positions 0 0 0 0 0 0 --directions 1 0 0 -1 0 0 --times 0 0
}

function ibd(){
   python $TUTORIALROOT/share/tut_detsim.py --evtmax 10 hepevt --exe IBD --volume pTarget --material LS
}

function offline-info(){
 
 echo  "TUTORIALROOT == " $TUTORIALROOT 
 echo "JUNOTOP == "  $JUNOTOP 
 echo "WORKTOP == "  $WORKTOP 
 echo "you can type tds-cmd to see what bash function you can use." 
 
}
function cmt-make-all(){
 
  if [ -d "$WORKTOP/offline/Examples/Tutorial/cmt/" ]; then
    pushd $WORKTOP/offline/Examples/Tutorial/cmt
    cmt br cmt config  
    source setup.sh
    cmt br cmt make
    popd
  fi

 
}
 
function de-job(){

   local job=$@
  # echo $job
   for c in $job
   do
     #echo $c
     id=$(hep_q -u | awk '{print $1,$9}'| grep $c | awk '{print $1}')
     commad=$(hep_q -u | awk '{print $1,$9}'| grep $c | awk '{print $2}')
     echo  "these jobs will be delete! "
     echo  $commad  
     read -p "are you sure delete?(y/n) " flag
 
     if [ $flag != "y" ] 
     then
        echo "ok! we pass these files!"
        break
     fi    

       
    # echo $id
     for j in $id
     do
       # echo $j
        hep_rm $j
     done
   echo $commad " have/has been delete!!"
   done
 
 
}



