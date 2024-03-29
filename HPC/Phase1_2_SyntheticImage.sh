#!/bin/bash
#SBATCH --partition generalsky
##SBATCH --partition=EpycPriority
##SBATCH --account=zhz18039
##SBATCH --partition=OSGPriority
##SBATCH --account=osgusers
##SBATCH --exclude=cn355,cn406,cn217,cn373,cn67,cn87,cn376
##SBATCH --partition=generalepyc
##SBATCH --account=osgusers
#SBATCH --share
#SBATCH --ntasks 2
#SBATCH --array 1-4
#SBATCH --mail-type=END                       
#SBATCH --mail-user=xiucheng.yang@uconn.edu  

module load matlab/2019b
# Replace with your application's commands
cd /home/xiy19029/CTUnderstoryMaping/CalculateVariables/
matlab -nodisplay -nosplash -singleCompThread -r 'batchGenerateSyntheticImages($SLURM_ARRAY_TASK_ID, $SLURM_ARRAY_TASK_MAX)'\;exit\; 
echo 'Finished Matlab Code at '