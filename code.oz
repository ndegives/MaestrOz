% Degives Nicolas 35141700
% Heroufosse Gauthier 50621700
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
      local ToExt
         fun {StretchAux Fact Part}
            case Part
            of H|T then
               case H
               of note(name:A octave:B sharp:C duration:D instrument:E) then note(name:A octave:B sharp:C duration:D*Fact instrument:E) | {StretchAux Fact T} % Pour les notes
               [] X|Y then {StretchAux Fact H} | {StretchAux Fact T} % Pour les accords
               [] silence(duration:D) then silence(duration:D*Fact) | {StretchAux Fact T} % Pour les silences
               end
            [] nil then nil
            end
         end
      in
         ToExt = {PartitionToTimedList Part}
         {StretchAux Fact ToExt}
      end
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Repeats the note a number (Amount) of times
   % Input : A note (Note) and a number of repetitions (Amount)
   % Output : A list with Amount times note

   fun {Drone Amount Note}
      fun {Addc Amount Acc}
         if Amount >= 1 then {Addc Amount-1 {Append Acc Note}}
         else Acc
         end
      end
   in 
        {Addc Amount nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Transposes the notes a certain number of semitones up (positive) or down (negative)
   % Input : N the number of semitones of difference and note the note to transpose
   % Output : Semitone transfomer note

      fun {TransposeNotes N Notes}
       fun {TransposeNote Note Acc}
         case Note 
         of H|T then [{TransposeNote H 0} {TransposeNote T 0}]
            [] nil then Note
         else
            if N>0 then
               if Acc<N then
                  case Note.name
                  of c then
                     if Note.sharp == false then {TransposeNote note(name:c octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc+1}
                     else {TransposeNote note(name:d octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc+1}
                     end
                  [] d then
                     if Note.sharp == false then {TransposeNote note(name:d octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc+1}
                     else {TransposeNote note(name:e octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc+1}
                     end
                  [] e then {TransposeNote note(name:f octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc+1}
                  [] f then
                     if Note.sharp == false then {TransposeNote note(name:f octave:Note.octave sharp:true duration:Note.duration instrument : Note.instrument) Acc+1}
                     else {TransposeNote note(name:g octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc+1}
                     end
                  [] g then
                     if Note.sharp == false then {TransposeNote note(name:g octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc+1}
                     else {TransposeNote note(name:a octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc+1}
                     end
                  [] a then
                     if Note.sharp == false then {TransposeNote note(name:a octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc+1}
                     else {TransposeNote note(name:b octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc+1}
                     end
                  [] b then {TransposeNote note(name:c octave:Note.octave+1 sharp:false duration:Note.duration instrument:Note.instrument) Acc+1}
                  else Note 
                  end
               else Note
               end
            elseif N<0 then
               if Acc>N then
                  case Note.name
                  of b then {TransposeNote note(name:a octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc-1}
                  [] a then
                     if Note.sharp==true then {TransposeNote note(name:a octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc-1}
                     else {TransposeNote note(name:g octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc-1}
                     end
                  [] g then
                     if Note.sharp==true then {TransposeNote note(name:g octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc-1}
                     else {TransposeNote note(name:f octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc-1}
                     end
                  [] f then
                     if Note.sharp==true then {TransposeNote note(name:f octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc-1}
                     else {TransposeNote note(name:e octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc-1}
                     end
                  [] e then {TransposeNote note(name:d octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc-1}
                  [] d then
                     if Note.sharp==true then {TransposeNote note(name:d octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc-1}
                     else {TransposeNote note(name:c octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument) Acc-1}
                     end
                  [] c then
                     if Note.sharp==true then {TransposeNote note(name:c octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument) Acc-1}
                     else {TransposeNote note(name:b octave:Note.octave-1 sharp:false duration:Note.duration instrument:Note.instrument) Acc-1}
                     end
                     else Note
                  end
               else Note
               end
            end
         end
      end
    in {TransposeNote Notes 0}
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Prend une partition et transforme chaque note de Semitones semitons
   % Output : Retourne la partition de notes transform??es
   fun {Transpose Semitones Part}
      case Part
      of H|T then case H
         of Note then {TransposeNotes Semitones {NoteToExtended H}} | {Transpose Semitones T}
         [] note(name:A octave:B sharp:C duration:D instrument:E) then {TransposeNotes Semitones note(name:A octave:B sharp:C duration:D instrument:E)} | {Transpose Semitones T}
         [] silence(duration:D) then H|{Transpose Semitones T}
         else {Transpose Semitones {NoteToExtended H}}|{Transpose Semitones T}
         end
      else nil
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   % Fonction fournie par les enseignants

   fun {NoteToExtended Note}
      case Note
      of H|T then {ChordToExtended Note}
      [] Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] note(name:A octave:B sharp:C duration:D instrument:E) then note(name:A octave:B sharp:C duration:D instrument:E)
      [] silence(duration:D) then silence(duration:D)
      [] Atom then
         if {HasFeature Atom duration} then Atom
         else
            case {AtomToString Atom}
            of [_] then
               note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
            [] [N O] then
               note(name:{StringToAtom [N]}
                  octave:{StringToInt [O]}
                  sharp:false
                  duration:1.0
                  instrument:none)
            else silence(duration:1.0)
            end
         end
      end
   end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {ChordToExtended Chord}
      case Chord
      of nil then
         nil
      [] H|T then
            case H of X|Y then 
                {ChordToExtended H}
            else 
                {NoteToExtended H}|{ChordToExtended T}
            end
        end
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Input : Part de type liste [a2 a3 a4] extNote|Note|Chord|ExtChord|Transformation
   % Output : Retourne une ext list

   fun {PartitionToTimedList Partition}
      fun {Aux Partition Acc}
         case Partition
         of H|T then
            case H
            of duration(seconds:A P) then {Aux T {Append Acc {Duration A P}}}
            [] stretch(factor:A P) then {Aux T {Append Acc {Stretch A P}}}
            [] drone(note:Note amount:Amount) then {Aux T {Append Acc {Drone Amount {Aux [Note] nil}}}}
            [] transpose(semitones:N P) then {Aux T {Append Acc {Transpose N P}}}
            [] silence(duration:D) then {Aux T {Append Acc [silence(duration:D)]}}
            [] Note then {Aux T {Append Acc [{NoteToExtended H}]}}
            [] note(name:A octave:B sharp:C duration:D instrument:E) then {Aux T {Append Acc [note(name:A octave:B sharp:C duration:D instrument:E)]}}
            [] Name#Octave then {Aux T {Append Acc [{NoteToExtended H}]}}
            [] X|Y then {Aux T {Append Acc [{Aux X|Y nil}]}}
         %   [] X|Y then if {HasFeature X duration} then {Aux T {Append Acc H}}
          %          else {Aux Y {Append Acc {NoteToExtended X}}}|{Aux T Acc}
           %         end
            else {Aux T Acc}
            end
         else Acc
         end
      end
   in
      {Aux Partition nil}
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
            else N=~4.0
	    		end
   	 	[] g then
	       	if Note.sharp then N=~1.0
	       	else N=~2.0
	    	   end
   	 	[] a then
	       	if Note.sharp then N=1.0
	       	else N=0.0
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
   % Output : Retourne une liste longue de 44100 ??chantillons * la dur??e de la note corresponants ?? la variation de fr??quence de la note

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


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Input : Prend une partition
   % Output : Transforme l'ensemble de la partition en ??chantillons gr??ce ?? la fonction Sample en proc??dant note par note

   fun {PartitionToSample Fonc Part}
      local ToExt
         fun {PartitionToSampleAux Part}
            case Part
		      of H|T then
			      case H
			      of X|Y then
				      {Append {Chord2Sample H} {PartitionToSampleAux T}}
			      [] nil then nil
			      else
                  {Append {Samples H} {PartitionToSampleAux T}}
			      end
		      else nil
		      end
         end
      in
         ToExt = {Fonc Part}
         {PartitionToSampleAux ToExt}
      end
   end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Input : Prend un accord
   % Output : Retourne une liste d'??chantillons qui correspond ?? la moyenne des ??chantillons de chaque note

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
          end
       [] H|nil then
          case H of I#M then {Map {Mix PartitionToTimedList M} fun {$ A I} A*I end}
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

   fun {Add L1 L2}
      if {List.length L1} \= {List.length L2} then
        if {List.length L1} > {List.length L2} then {Add L1 {Append L2 {Map {List.number 1 ({List.length L1}-{List.length L2}) 1} fun {$ A} {IntToFloat A*0} end}}}
        else {Add L2 {Append L1 {Map {List.number 1 ({List.length L2}-{List.length L1}) 1} fun {$ A} {IntToFloat A*0} end}}}
        end
      else {Sum L1 L2}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Prend deux listes de m??me taille et en retourne la somme

   fun{Sum X Y}
      case X
      of H|nil then
         H+Y.1|nil
      [] H|T then
         H+Y.1|{Sum T Y.2}
      else
         nil
      end
  end




   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input :
   % Output :
   % !! A modifier

   fun {Echo Delay Decay Music}
      local E in
         E = {Append {Map {List.number 1 {FloatToInt {Round Delay*44100.0}} 1} fun {$ A} {IntToFloat A*0} end} Music}
         {Merge [1.0#Music Decay#E]}
      end
   end


   % Si intensit?? ?? 0.5 => 0.66 & 0.33
   % Si intensit?? ?? 0.33 => 0.75 & 0.25
   % Si intensit?? ?? 0.25 => 0.8 & 0.2
   % Si intensit?? ?? 0.2 =>  0.833 & 0.166

   % On passe chaque fois de 1/2 intensit?? souhait??e ?? 1/3 , 1/4 ?? 1/5 etc


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Purpose : take a music and start playing increasly, and stop playing decreasly
   % Input : Start : Time which the mus
   %         Out :
   %         Music :
   % Output :
   fun {Fade Start Out Music}
      local Deb P1 Fin P3 P2 in
         Deb = {List.take Music {FloatToInt (44100.0*Start)}}
         P1 = {List.mapInd Deb fun{$ I A} A*1.0/(Start*44100.0)*{IntToFloat (I-1)} end}
         Fin = {List.drop Music {FloatToInt {IntToFloat {List.length Music}}-(Out*44100.0)}}
         P3 = {List.mapInd Fin fun {$ I A} A*(1.0-(1.0/(Out*44100.0))*{IntToFloat I}) end}
         P2 = {List.take {List.drop Music {FloatToInt Start*44100.0}} {List.length Music}-{FloatToInt Start*44100.0}-{FloatToInt Out*44100.0}}
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
            {Append {PartitionToSample P2T P} {Mix P2T T}}
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


   Music = {Project.load CWD#'test.P2T.oz'}
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
   {ForAll [NoteToExtended Music Samples PartitionToSample Merge Stretch Length] Wait}

   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}

   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
