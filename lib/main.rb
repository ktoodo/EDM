module Marriage
  def bond
    @swing_score
  end
end

class Elves
  attr_accessor :name, :married, :married_to, :proposed_to
  include Marriage

  def initialize(name, proposed_to = [])
    @name = name
    @married = false
    @proposed_to = proposed_to
  end

  def propose_to(dwarf_name, score, edm)
    @proposed_to.push(dwarf_name)
    if Edm.dwarves[dwarf_name].married == false
      marry_to(dwarf_name, score)
      Edm.dwarves[dwarf_name].accept_proposal(self.name, score)
    else
      previous_proposal_by = Edm.dwarves[dwarf_name].married_to
      previous_proposal_score = Edm.dwarves[dwarf_name].bond
      if score[0] > previous_proposal_score[0] && score[1] > previous_proposal_score[1]
        marry_to(dwarf_name, score)
        Edm.dwarves[dwarf_name].accept_proposal(self.name, score)
        edm.set(Elves, previous_proposal_by, Edm.elves[previous_proposal_by].proposed_to)
      end
    end
  end

  def marry_to(name, score)
    @married = true
    @married_to = name
    @swing_score = score
  end

end

class Dwarves
  attr_reader :name, :married, :married_to
  include Marriage

  def initialize(name)
    @name = name
    @married = false
  end

  def consider_proposal(swings, swing_type)
  end

  def accept_proposal(name, score)
    @married = true
    @married_to = name
    @swing_score = score
  end
end

class Edm
  attr_reader :elves, :dwarves
  @@elves = {}
  @@dwarves = {}

  def set(race, name, proposed_to = [])
    if race == Elves
      elf = race.new(name, proposed_to)
      @@elves[name] = elf
    else
      dwarf = race.new(name)
      @@dwarves[name] = dwarf
    end
  end

  def self.elves
    @@elves
  end

  def self.dwarves
    @@dwarves
  end

  def import_data(file)
    fname = "Tests/#{file}"
    File.foreach(fname) do |line| 
      if line.start_with?('Elves: ')
        line = line.gsub(/,/, '').split()
        line -= ['Elves:']
        line.each {|elf| set(Elves, elf)}
      elsif line.start_with?('Dwarves: ')
        line = line.gsub(/,/, '').split()
        line -= ['Dwarves:']
        line.each {|dwarf| set(Dwarves, dwarf)}
      else
        line = line.gsub(/[:=x]/, "").squeeze(" ").split
        elf = line[0]
        dwarf = line[1]
        score = []
        score << score_translate(line[2])
        score << score_translate(line[3])
        puts "#{elf} and #{dwarf} and #{score}"
        p @@elves[elf].propose_to(dwarf, score, self)
      end
    end
    print_result
  end

  def score_translate(score)
    if score.include?("L")
      score.split
      score = "-#{score[0]}".to_i
    else
      score.split
      score = "#{score[0]}".to_i
    end
  end

  def print_result
    @@elves.each {|key, elf| p "#{elf.name} : #{elf.married_to}" if elf.married}
  end

  def debug
    @@elves.each {|key, elf| p elf}
    @@dwarves.each {|key, dwarf| p dwarf}
  end
end

#ave = Elves.new('Ave')
#duthilia = Dwarves.new('Duthilia')

edm = Edm.new
edm.import_data('test1')
edm.debug
# edm.set(Elves ,'Ave')
# edm.set(Elves ,'Elegast')
# edm.set(Dwarves, 'Duthilia')
# p Edm.elves["Ave"]
# p Edm.dwarves["Duthilia"]
# p Edm.elves["Elegast"]
# puts Edm.elves["Ave"].propose_to(Edm.dwarves["Duthilia"].name, [1, 1], edm)
# p Edm.elves["Ave"]
# puts Edm.elves["Elegast"].propose_to(Edm.dwarves["Duthilia"].name, [1,1], edm)
# p Edm.elves["Ave"]
# p Edm.elves["Elegast"]
# p Edm.dwarves["Duthilia"]

