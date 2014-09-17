
The toy assembly data & code for parsing
---------------------------------------------

From Stochastic Grammar to Bayes Network: Probabilistic Parsing of Complex Activity. 
Nam N. Vo and Aaron F. Bobick. CVPR 2014.

Note that this is not the original code used in the paper.
If you find bugs, please contact us at: namvo@gatech.edu.

///////////////////////////////
// Data
///////////////////////////////
grammar.txt specifies the temporal structure of the activity
[sequence].avi  
[sequence].txt  actions labels
[sequence].handsdetections.txt the (x,y) position of hands in each frame (no left/right hand specified)

///////////////////////////////
// Parsing Code
///////////////////////////////
The SIN code has to be downloaded separately and added to Matlab PATH.
Run main.m to load the data, perform training, and parsing on 1 test sequence.
You can change:
- training_ids and testing_ids in main.m to choose which examples will be trained/tested
- online_parsing in main.m to switch between offline & online inference
- inference_skip_rate, time_scale in main.m to "forward" the online inference
- start_names in viz_inference.m to choose which action timings are ploted.


