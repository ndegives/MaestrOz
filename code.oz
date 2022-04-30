% Degives Nicolas 35141700
% Heroufosse Gauthier
% Date : April 2022
local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   CWD = 'C:/Nico/Github/MaestrOz/' % Put here the **absolute** path to the project files
   [Project] = {Link [CWD#'Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns the duration (seconds) of a score by adding the duration of each note/silence
   % If chord, take only the first note since chord = several notes at the same time
   % Input : A partition (Part)
   % Output : The duration of the partition

   fun {Length Part}
      fun {LengthA L Acc}
         case L of H|T then
            case H
            of drone(note:A amount:P) then
               {LengthA {Append {Drone A P} T} Acc}
            [] transpose(semitones:A P) then
               {LengthA {Append {Transpose A P} T} Acc}
            [] stretch(factor:A P) then
               {LengthA {Append {Stretch A P} T} Acc}
            [] duration(seconds:A P) then
               {LengthA {Append {Duration A P} T} Acc}
            [] X|Y then
               if {HasFeature X duration} then {LengthA T Acc+X.duration}
               else
                  {LengthA T Acc+1.0}
               end
            [] Atom#Octave then
               {LengthA T Acc+1.0}
            [] Atom then
               if {HasFeature H duration} then
                  {LengthA T Acc+H.duration}
               else
                  {LengthA T Acc+1.0}
               end
            end
         [] nil then Acc
         else
            0.0
         end
      end
   in
      {LengthA Part 0.0}
   end

	%   declare
   % Part = c|silence(duration:2.0)|nil

   % {Browse {Length Part}}
		
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Sets the duration of the partition to the specified number of seconds.
   % Adapts the duration of each note/silence according to the initial duration
   % Input : Time : the time in secondes ; Part : the partition
   % Output : The partition (Part) adjusted to the time (Time)
   fun {Duration Time Part}
      local L in
         L={Length Part}
         {Stretch Time/L Part}
         % Stretch function stretches each note one by one
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Stretch the duration of the partition by stretching each note by the factor Fact
   % Input : Stretch factor (F) and partition to be stretched
   % Output : The stretched score (each sound/silence is stretched)
   fun {Stretch Fact Part}
      case Part
      of H|T then
         case H 
         of note(name:A octave:B sharp:C duration:D instrument:E) then note.duration = D*Fact | {Stretch Fact T} % Pour les notes
         [] X|Y then {Stretch Fact X|Y} | {Stretch Fact T} % Pour les accords
         [] silence(duration:D) then silence.duration = D*Fact | {Stretch Fact T} % Pour les silences
         end
      [] nil then nil
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Repeats the note a number (Amount) of times
   % Input : A note (Note) and a number of repetitions (Amount)
   % Output : A list with Amount times note
   fun {Drone Note Amount}
      fun {Add Amount Acc}
         if Amount >= 1 then {Add Amount-1 {Append Acc Note}}
         else Acc
         end
      end
   in {Add Amount nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Transposes the notes a certain number of semitones up (positive) or down (negative)
   % Input : N the number of semitones of difference and note the note to transpose
   % Output : Semitone transfomer note
   fun {TransposeNotes N Notes}
      fun {TransposeNote Note Acc}
         if Acc>0 then
            if Acc<N then
               case Note.name 
               of c then
                  if Note.sharp == flase then {TransposeNote note(name:c octave:Note.octave sharp:true duration:note.duration instrument : note.instrument) Acc+1}
                  else {TransposeNote note(name:d octave:Note.octave sharp:false duration:note.duration instrument : note.instrument) Acc+1}
                  end
               [] d then
                  if Note.sharp == false then {TransposeNote note(name:d octave:Note.octave sharp:true duration:note.duration instrument : note.instrument) Acc+1}
                  else {TransposeNote note(name:e octave:Note.octave sharp:false duration:note.duration instrument : note.instrument) Acc+1}
                  end
               [] e then {TransposeNote note(name:f octave:Note.octave sharp:false duration:note.duration instrument : note.instrument) Acc+1}
               [] f then
                  if Note.sharp == false then {TransposeNote note(name:f octave:Note.octave sharp:true duration:note.duration instrument : note.instrument) Acc+1}
                  else {TransposeNote note(name:g octave:Note.octave sharp:false duration:note.duration instrument : note.instrument) Acc+1}
                  end
               [] g then
                  if Note.sharp == false then {TransposeNote note(name:g octave:Note.octave sharp:true duration:note.duration instrument : note.instrument) Acc+1}
                  else {TransposeNote note(name:a octave:Note.octave sharp:false duration:note.duration instrument : note.instrument) Acc+1}
                  end
               [] a then
                  if Note.sharp == false then {TransposeNote note(name:a octave:Note.octave sharp:true duration:note.duration instrument : note.instrument) Acc+1}
                  else {TransposeNote note(name:b octave:Note.octave sharp:false duration:note.duration instrument : note.instrument) Acc+1}
                  end
               [] b then {TransposeNote note(name:c octave:Note.octave+1 sharp:false duration:note.duration instrument : note.instrument) Acc+1}
               end
            else Note
            end
         elseif Acc<0 then
            if Acc>N then
               case Note.name
               of b then {TransposeNote note(name:a octave:Note.octave sharp:true duration:note.duration instrument:note.instrument) Acc-1}
               [] a then
                  if Note.sharp==true then {TransposeNote note(name:a octave:Note.octave sharp:false duration:note.duration instrument:note.instrument) Acc-1}
                  else {TransposeNote note(name:g octave:Note.octave sharp:true duration:note.duration instrument:note.instrument) Acc-1}
                  end
               [] g then
                  if Note.sharp==true then {TransposeNote note(name:g octave:Note.octave sharp:false duration:note.duration instrument:note.instrument) Acc-1}
                  else {TransposeNote note(name:f octave:Note.octave sharp:true duration:note.duration instrument:note.instrument) Acc-1}
                  end
               [] f then
                  if Note.sharp==true then {TransposeNote note(name:f octave:Note.octave sharp:false duration:note.duration instrument:note.instrument) Acc-1}
                  else {TransposeNote note(name:e octave:Note.octave sharp:false duration:note.duration instrument:note.instrument) Acc-1}
                  end
               [] e then {TransposeNote note(name:d octave:Note.octave sharp:true duration:note.duration instrument:note.instrument) Acc-1}
               [] d then 
                  if Note.sharp==true then {TransposeNote note(name:d octave:Note.octave sharp:false duration:note.duration instrument:note.instrument) Acc-1}
                  else {TransposeNote note(name:c octave:Note.octave sharp:true duration:note.duration instrument:note.instrument) Acc-1}
                  end
               [] c then
                  if Note.sharp==true then {TransposeNote note(name:c octave:Note.octave sharp:false duration:note.duration instrument:note.instrument) Acc-1}
                  else {TransposeNote note(name:b octave:Note.octave-1 sharp:false duration:note.duration instrument:note.instrument) Acc-1}
                  end
               end
            else Note
            end
         end
      end
   in {TransposeNote Notes 0}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Prend une partition et transforme chaque note de Semitones semitons
   % Output : Retourne la partition de notes transformées
   fun {Transpose Semitones Part}
      case Part
      of H|T then {TransposeNotes Semitones H} | {Transpose Semitones T}
      [] nil then nil
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   % Fonction fournie par les enseignants
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {ChordToExtended Chord}
      case Chord
      of nil then
         nil
      [] H|T then
         {NoteToExtended H}|{ChordToExtended T}
      end
   end
	
	
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Input : Part de type liste [a2 a3 a4] extNote|Note|Chord|ExtChord|Transformation
   % Output : Retourne une ext list
   fun {PartitionToTimedList Partition}
      fun {Acc Partition Acc}
         case Partition 
         of H|T then case H
            of duration(seconds:A P) then {Acc T {Append Acc {Duration A P}}}
            [] stretch(factor:A P) then {Acc T {Append Acc {Stretch A P}}}
            [] drone(note:Note amount:Amount) then {Acc T {Append Acc {Drone Note Amount}}}
            [] transpose(semitones:N P) then {Acc T {Append Acc {Transpose N P}}}
            [] silence(duration:A) then {Acc T {Append Acc silence(duration:A)}}
            [] Note then {Acc T {Append Acc {NoteToExtended Note}}}
            [] note(name:A octave:B sharp:C duration:D instrument:E) then {Acc T {Append Acc note(name:A octave:B sharp:C duration:D instrument:E)}}
				[] X|Y then % Accord
               		{Acc T {Append Acc {ChordToExtended H}}}
            else Acc
            end
         else Acc
         end
      end
   in {Acc Partition nil}
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : extended note as arg
   % Output : return the height in comparison to A4
      
   fun {Hauteur Note}
      local Oct N in
         Oct = {IntToFloat Note.octave} - 4.0
         case Note.name 
         of c then
            if Note.sharp then N=~8.0
            else N=~9.0
            end
         [] d then
            if Note.sharp then N=~6.0
            else N=~7.0
            end
         [] e then
            N=~5.0
         [] f then
            if Note.sharp then N=~3.0
            else
	       		N=~4.0
	    		end
   	 	[] g then
	       	if Note.sharp then N=~1.0
	       	else
	        		N=~2.0
	    	   end
   	 	[] a then
	       	if Note.sharp then N=1.0
	       	else
	       		N=0.0
	    	   end
         [] b then N=2.0
	    	end
	 	   12.0 * Oct + N
      end
   end
             
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : extended note 
   % Output : return the associated frq 
      
   fun {Freq Note}
      {Pow 2.0 {Hauteur Note}/12.0}*440.0      
   end
  
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
	% Input : Prend une extendednote en
   % Output : Retourne une liste longue de 44100 échantillons * la durée de la note corresponants à la variation de fréquence de la note
   fun {Samples Note}
      local Pi
         fun {SamplesAux N Acc}
            case N
            of silence(duration:D) then
               if Acc =< 44100.0*N.duration then
                  0.0 | {SamplesAux N Acc+1.0}
               else nil
               end
            else
               if Acc =< 44100.0*N.duration then
                  0.5*({Sin (2.0*Pi*{Freq N}*Acc)/44100.0}) |  {SamplesAux N Acc+1.0}
               else
                  nil
               end
            end
         end
      in
         Pi = 3.141592
      {SamplesAux Note 1.0}
      end
   end

	% {Browse {Samples {NoteToExtended a}}} ça marche !!!!
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Input : Prend une partition 
   % Output : Transforme l'ensemble de la partition en échantillons grâce à la fonction Sample en procédant note par note
      
   fun {PartitionToSample Part}
		case Part 
		of H|T then 
			case H 
			of X|Y then
				{Append {Chord2Sample H} {PartitionToSample T}}
			[] nil then nil
			else {Append {Samples H} {PartitionToSample T}}
			end
		else nil
		end	
   end
   
      
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Input : Prend un accord 
   % Output : Retourne une liste d'échantillons qui correspond à la moyenne des échantillons de chaque note
      
   fun {Chord2Sample Chord}
      case Chord
      of H|nil then {Samples H}
      [] H|T then
         {Mean {Samples H} {Chord2Sample T}}
      else nil
      end
   end	
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Input : two lists of same size
	% Output : Return the mean of the two lists
	fun {Mean X Y}
	   case X of H|nil then
			(H+Y.1)/2.0|nil
		[] H|T then
			(H+Y.1)/2.0|{Mean T Y.2}
		else nil
		end
	end
			
			
			
			
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : list of musics (each with its intensities) to be played in the same time
   % Output : Sum of the musics in one music
   % !! A modifier
   fun {Merge Musics}
      case Musics
      of H|T then case H
         of I#M then {Add {Map {Mix PartitionToTimedList M} fun {$ A I} A*I end} {Merge T}}
         else nil
         end
      [] H|nil then
         case H of I#M then {Map {Mix PartitionToTimedList M} fun {$ A I} A*I end}
         else nil
         end
      end
   end
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : relative path to a .wav file (string)
   % Output : list of samples of the .wav file
      
   fun {Wave File}
      {Project.load File}
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Music : a list of sample
   % Output : The reversed music. It reverses the order of the samples
   fun {Reverse Music}
      {List.reverse Music}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Amount : natural ; Music
   % Output : The music with amount repetition
   fun {Repeat Amount Music}
      fun {RepeatA Amount Music Acc}
         if Amount > 0 then {RepeatA Amount-1 Music {Append Acc Music}}
         else Acc
         end
      end
   in {RepeatA Amount Music nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Duration (float): in seconds ; Music
   % Output : The music played in loop on the time of the duration. The last repetition is truncated to not exceed the duration
   fun {Loop Duration Music}
      fun {LoopN Duration Music N}
         if N=< {FloatToInt Duration*44100.0} then case Music
            of H|T then H|{LoopN Duration T N+1}
            [] H|nil then H|{LoopN Duration Music N+1}
            end
         else nil
         end
      end
   in {LoopN Duration Music 1}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Low and High (float) : Boundaries ; Music
   % Output : 
   fun {Clip Low High Music}
      case Music
      of H|T then 
         if H>High then High|{Clip Low High T}
         elseif H<Low then Low|{Clip Low High T}
         else H|{Clip Low High T}
         end
      else nil
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Two list with same length or not
   % Output : Sum of the two list
   % Pas sur du résultat !!!
   fun {Add L1 L2}
      if {List.length L1} \= {List.length L2} then
        if {List.length L1}>{List.length L2} then {List.zip L1 {Append L2 {Map {List.number 1 ({List.length L1}-{List.length L2}) 1} fun {$ A} A*0 end}} fun {$ A B} A+B end}
        else {List.zip {Append L1 {Map {List.number 1 ({List.length L2}-{List.length L1}) 1} fun {$ A} A*0 end}} L2 fun {$ A B} A+B end}
        end
      else {List.zip L1 L2 fun {$ A B} A+B end}
      end
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input :
   % Output :
   % !! A modifier
   fun {Echo Delay Decay Music}
      local E in
         E = {Append {Map {List.number 1 {FloatToInt Delay*44100.0} 1} fun {$ A} A*0 end} Music}
         {Merge [1.0#Music Decay#E]}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Purpose : take a music and start playing increasly, and stop playing decreasly
   % Input : Start : Time which the mus
   %         Out : 
   %         Music :
   % Output :
   fun {Fade Start Out Music}
      local Deb P1 Fin P3 P2 in
         Deb = {List.take Music {FloatToInt (44100.0*Start)}} % Identidie le debut
         P1 = {List.mapInd Deb fun{$ I A} A*1.0/(Start*44100.0)*{IntToFloat (I-1)} end} % Applique le fondu 
         Fin = {List.drop Music {FloatToInt {IntToFloat {List.length Music}}-(Out*44100.0)}} %Identifie la fin
         P3 = {List.mapInd Fin fun {$ I A} A*(1.0-(1.0/(Out*44100.0))*{IntToFloat I}) end} % Applique le fondu
         P2 = {List.take {List.drop Music {FloatToInt Start*44100.0}} {List.length Music}-{FloatToInt Start*44100.0}-{FloatToInt Out*44100.0}} %Recupere le milieu
         {Append {Append P1 P2} P3}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Start and Out are float, Music is a list of sample
   % Output : Cut the music between Start and Out boundaries
   fun {Cut Start Finish Music}
     fun {Rec N Liste}
         if N =< {FloatToInt Finish*44100.0} then
            case Liste
            of H|T then
               if N < {FloatToInt Start*44100.0} then {Rec N+1 T}
               else H|{Rec N+1 T}
               end
            else 0.0|{Rec N+1 nil}
            end
         else nil
         end
      end
   in {Rec 1 Music}
   end
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
		
	% Tests pour la partie Mix : Run les fonctions à tester auparavant sans oublier le fameux "declare"
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
	%declare
	%{Browse 4} % Test de la console

	%	Note = a#3
	%	{Browse {NoteToExtended Note}}	% Test de {NoteToExtended}
	
	%{Browse {Mean 10.0|nil 4.0|3.0|nil}} % Test de {Mean}		

	%{Browse {Sample {NoteToExtended Note}}} % Test de {Sample}
   %Note1 = {NoteToExtended a}
   %Note2 = {NoteToExtended b}

	%	Acc = Note1|Note2|nil
   %{Browse Acc}
   %{Browse {Chord2Sample Acc}} % Test de {Chord2Sample}
		
	%	Tune = [a|b|nil] % Ceci est un accord vu la façon dont il est inséré dans la partition au-dessous 
	%	Partition = {Flatten [Tune|a|nil]} % Ceci est une partition

	%	{Browse {Partition2Sample Partition}} % Test de {Partition2Sample}
		
		

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : prend une fonction P2T et une musique Music en argument
   % Output :retourne une liste de samples		
   % Input : prend une fonction P2T et une musique Music en argument
   % Output :retourne une liste de samples
   fun {Mix P2T Music}
	   case Music
	   of H|T then
		   case H
         of samples(P) then
            {Append P {Mix P2T T}}
         [] partition(P) then
            {Append {PartitionToSample P} {Mix P2T T}}
         [] wave(P) then
            {Append {Wave P} {Mix P2T T}}
         [] merge(P) then
            {Append {Merge P} {Mix P2T T}}
         [] reverse(P) then
            {Append {Reverse P} {Mix P2T T}}
         [] repeat(amount:A P) then
            {Append {Repeat A P} {Mix P2T T}}
         [] loop(seconds:A P) then
            {Append {Loop A P} {Mix P2T T}}
         [] clip(low:A high:B P) then
            {Append {Clip A B P} {Mix P2T T}}
         [] echo(delay:T decay:A P) then
            {Append {Echo T A P} {Mix P2T T}}
         [] fade(start:A out:B P) then
            {Append {Fade A B P} {Mix P2T T}}
         [] cut(start:A finish:B P) then
            {Append {Cut A B P} {Mix P2T T}}
         else
            nil
         end
      else
         nil
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert '/full/absolute/path/to/your/tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
