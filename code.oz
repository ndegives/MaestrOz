% Degives Nicolas 35141700
% Heroufosse Gauthier
% Date : April 2022
local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   CWD = 'C:/Nico/Github/MaestrOz' % Put here the **absolute** path to the project files
   [Project] = {Link [CWD#'Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns the duration (seconds) of a score by adding the duration of each note/silence
   % If chord, take only the first note since chord = several notes at the same time
   % Input : A partition (Part)
   % Output : The duration of the partition
   fun {Length Part}
      fun {LengthA Part Acc}
         case Part of
         H|T then
            case H
            of note(name:A octave:B sharp:C duration:D instrument:E)|X then {Length T Acc+D}
            [] note(name:A octave:B sharp:C duration:D instrument:E) then {Length T Acc+D}
            [] silence(duration:D) then {Length T Acc+A}
            else 0
            end
         [] nil then Acc
      end
   in {LengthA Part 0} 
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
   in {TransposedNote Note 0}
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
   % Input :
   % Output :

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
      {Pow 2.O {Hauteur Note}/12.0}*440.0      
   end
  
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
   %PAS FINIE 
   % Input : 
   % Output : 
   fun {Samples Note}
	local Pi 
      		fun {SamplesAux N Acc}
			case N 
			of silence(duration:D) then
				if Acc< 44100.0*N.duration % Generation when we are still in the duration
			        	0.0 | {SamplesAux N Acc+1.0}
        			else
					nil
				end
			[] note(duration:D) then 
				0.5*{Sin 2*Pi*{Freq Note}*Acc/44100.0} |  {SamplesAux N Acc+1.0}
			end
   	in 
		Pi = 3.14159265359
	   {SamplesAux Note 1.0}
	end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : A partition 
   % Output :
      
   fun {Partition}
      % TODO 
      
   end
   
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : list of musics (each with its intensities) to be played in the same time
   % Output : Sum of the musics in one music
      
   fun {Merge Musics}
      case Musics
      of H|T then case H
         of I#M then {Add {Mult I {Mix PartitionToTimedList M}} {Merge T}}
         else skip
         end
      [] H|nil then
         case H of I#M then {Mult I {Mix PartitionToTimedList M}}
         else skip
         end
      end
   end
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : relative path to a .wav file (string)
   % Output : list of samples of the .wav file
      
   fun {Wave File}
      {Project.readFile File}
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
         if Ammount > 0 then {RepeatA Amount-1 Music {Append Acc Music}}
         else Acc
         end
      end
   in {ReapeatA Amount Music nil}
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
   % Input :
   % Output :
   fun {Echo Delay Decay Music}
      {Add {Mult Decay {Decal Delay Music}} {Mix PartitionToTimedList}}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : Start :
   %         Out : 
   %         Music :
   % Output :
   fun {Fade Start Out Music}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input :
   % Output :
   fun {Cut Start Finish Music}

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : prend une fonction P2T et une musique Music en argument
   % Output :retourne une liste de samples		
   fun {Mix P2T Music}
	case Music 
	of H|T then 
		case H of samples(P) then {Append P {Mix P2T T}}
			[] partition(P)
	 		[] wave(P) then
	 		[] merge(P) then
	 		[] reverse(P) then
	 		[] repeat(amount:A P) then
	 		[] loop(seconds:A P) then
	 		[] clip(low:A high:B P) then
	 		[] echo(delay:T decay:A P) then
	 		[] fade(start:A out:B P) then
	 		[] cut(start:A finish:B P) then
			else
				skip %{Append nil $}
			end
		end
	end
      %{Project.readFile CWD#'wave/animals/cow.wav'}
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
