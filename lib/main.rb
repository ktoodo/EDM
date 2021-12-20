module Marriage
  #return previous marriage swing scores
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
    @proposed_to.push(dwarf_name) #remember all dwarves to whom the elf has proposed to
    #marry if both parties are unmarried
    if Edm.dwarves[dwarf_name].married == false && @married == false
      marry_to(dwarf_name, score)
      Edm.dwarves[dwarf_name].accept_proposal(@name, score)
    #check if married elf would like new unmarried dwarf more
    #if true / marry new and unmarry old
    elsif Edm.dwarves[dwarf_name].married == false && @married == true
      if (score[0] > self.bond[0])# && (score[1] > self.bond[1])
        edm.set(Dwarves, @married_to)
        marry_to(dwarf_name, score)
        Edm.dwarves[dwarf_name].accept_proposal(self.name, score)
      end
    #check if married dwarf would like new unmarried elf more
    #if true / marry new and unmarry old
    elsif Edm.dwarves[dwarf_name].married == true && @married == false
      previous_proposal_by = Edm.dwarves[dwarf_name].married_to
      previous_proposal_score = Edm.dwarves[dwarf_name].bond
      if (score[1] > previous_proposal_score[1])
        marry_to(dwarf_name, score)
        edm.set(Elves, previous_proposal_by, Edm.elves[previous_proposal_by].proposed_to)
        Edm.dwarves[dwarf_name].accept_proposal(self.name, score)
      end
    #check if both married partners would like eachother more than their previous partners
    elsif Edm.dwarves[dwarf_name].married == true && @married == true
      previous_proposal_by = Edm.dwarves[dwarf_name].married_to
      previous_proposal_score = Edm.dwarves[dwarf_name].bond
      #check if elf would like the new one more and if the dwarf would like a new partner more than the previous
      if ((score[0] > self.bond[0]) && (score[1] > previous_proposal_score[1]))
        edm.set(Dwarves, @married_to)
        marry_to(dwarf_name, score)
        edm.set(Elves, previous_proposal_by, Edm.elves[previous_proposal_by].proposed_to)
        Edm.dwarves[dwarf_name].accept_proposal(self.name, score)
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

  def initialize
    import_data('test2') #select file to read in
  end

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
      #read elves and create instances
      if line.start_with?('Elves: ')
        line = line.gsub(/,/, '').split()
        line -= ['Elves:']
        line.each {|elf| set(Elves, elf)}
      #read dwarves and create instances
      elsif line.start_with?('Dwarves: ')
        line = line.gsub(/,/, '').split()
        line -= ['Dwarves:']
        line.each {|dwarf| set(Dwarves, dwarf)}
      #analyze encounters till end of document
      else
        line = line.gsub(/[:=x]/, "").squeeze(" ").split
        elf = line[0]
        dwarf = line[1]
        score = []
        score << score_translate(line[2])
        score << score_translate(line[3])
        @@elves[elf].propose_to(dwarf, score, self)
      end
    end
    print_result
  end

  def score_translate(score)
    if score.include?("L")
      score = score.gsub("L", "")
      score = score.to_i * -1
    else
      score = score.gsub("R", "")
      score = score.to_i
    end
  end

  def print_result
    @@elves.each {|key, elf| p "#{elf.name} : #{elf.married_to}" if elf.married}
  end
end

edm = Edm.new
