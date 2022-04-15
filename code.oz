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
            [] nil then 0
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
   % Input : Facteur d'étirement (F) et partition à étirer
   % Output : La partition étirée (chaque son/silence est étiré)
   fun {Stretch Fact Part}
      fun {StretchA Y}
         case Y
         of note(name:A octave:B sharp:C duration:D instrument:E) then note.duration = D*Fact
         [] H|T then {Strecth Fact H|T}
         [] silence(duration:D) then silence.duration = Fact*D 
         [] nil then nil
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Repete la note (Note) un nombre (Amount) de fois
   % Input : Une note (Note) et un nombre de repetition (Amount)
   % Output : Une liste avec Amount fois la note
   fun {Drone Note Amount}
      Note =1
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Input : 
   % Output : 
   fun {Transpose Semitone}
      Semitone =1
   end
   

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
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

   fun {PartitionToTimedList Partition}
      % TODO
      case Partition of H|T then 
         case H
         of ... then ...
         [] ... then ...
         end
      [] nil then nil
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
