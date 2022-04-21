% Degives Nicolas 35141700
%
% Date : April 2022
local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   CWD = 'C:/Nico/Github/MaestrOz' % Put here the **absolute** path to the project files
   [Project] = {Link [CWD#'Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : 
   % Output : 
   fun {Notes P}
      P=1
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : 
   % Output : 
   fun {Chords P}
      P=1
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : 
   % Output : 
   fun {Identity P}
      P=1
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Renvoie la duree (secondes) d'une partition en additionnant la duree de chaque note/silence
   % Si accord, ne prend que la premiere note puisque accord=plusieurs notes en meme temps
   % Input : Une partition (Part)
   % Output : La durée de la partition
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
   % Fixe la duree de la partition au nombre de secondes indiqué.
   % Adapte la duree de chaque note/silence en fonction de la duree initiale
   % Input : Time : le temps (Time) en secondes et la partition (Part)
   % Output : La partition (Part) ajustée au temps (Time)
   fun {Duration Time Part}
      local L in
         L={Length Part}
         {Stretch Time/L Part}
         % Fonction Stretch etire chaque note une par une
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Etire la duree de la partition en etirant chaque note par le facteur Fact
   % Input : Facteur d'etirement (F) et partition à etirer
   % Output : La partition etiree (chaque son/silence est etire)
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
   % Repete la note (Note) un nombre (Amount) de fois
   % Input : Une note (Note) et un nombre de repetition (Amount)
   % Output : Une liste avec Amount fois la note
   fun {Drone Note Amount}
      fun {Add Amount Acc}
         if Amount >= 1 then {Add Amount-1 {Append Acc Note}}
         else Acc
         end
      end
   in {Add Amount nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Transpose les notes d un certain nombre de semi-tons vers le haut (positif) ou vers le bas (negatif)
   % Input : N le nombre de de semi-ton de difference et note la note a transposer
   % Output : Note transfomer de Semitone semi-tons
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
   % Input : partition 
   % Output :
      
   fun {Partition}
      % TODO 
      
   end
   
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Input : list of musics to be played in the same time
   % Output :
      
   fun {Merge}
      % TODO 
      
   end
  
   
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : relative path to a .wav file
   % Output : list of samples
      
   fun {Wave}
      % TODO 
      
   end
   
    
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile CWD#'wave/animals/cow.wav'}
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