class Elves
  attr_accessor :name, :married, :married_to, :proposed_to, :preferences

  def initialize(name, proposed_to = [], preferences = {})
    @name = name
    @married = false
    @proposed_to = proposed_to
    @preferences = preferences
  end

  def propose_to(dwarf_name, edm)
    @proposed_to.push(dwarf_name)
    #marry if both unmarried and have set preference for each other
    if Edm.dwarves[dwarf_name].preferences.include?(self.name) && Edm.dwarves[dwarf_name].married == false
      marry_to(dwarf_name)
      Edm.dwarves[dwarf_name].accept_proposal(@name)
    elsif Edm.dwarves[dwarf_name].married == true
      previous_proposal_by = Edm.dwarves[dwarf_name].married_to
      #marry if have set preference for each other and previous match is weaker + unmarry old match
      if Edm.dwarves[dwarf_name].preferences.include?(self.name) && Edm.dwarves[dwarf_name].preferences[self.name] > Edm.dwarves[dwarf_name].preferences[previous_proposal_by]
        edm.set(Elves, previous_proposal_by, Edm.elves[previous_proposal_by].proposed_to, Edm.elves[previous_proposal_by].preferences)
        marry_to(dwarf_name)
        Edm.dwarves[dwarf_name].accept_proposal(@name)
      end
    end
  end

  def marry_to(name)
    @married = true
    @married_to = name
  end
end

class Dwarves
  attr_reader :name, :married, :married_to, :preferences

  def initialize(name, preferences = {})
    @name = name
    @married = false
    @preferences = {}
  end

  def accept_proposal(name)
    @married = true
    @married_to = name
  end
end

class Edm
  attr_reader :elves, :dwarves
  @@elves = {}
  @@dwarves = {}

  def initialize
    import_data('test2') #select file to read in
    match_maker
    print_result
  end

  #create instance of elf or dwarf
  def set(race, name, proposed_to = [], preferences = {})
    if race == Elves
      elf = race.new(name, proposed_to, preferences)
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
      #analyze encounters and set preferences till end of document
      else
        line = line.gsub(/[:=x]/, "").squeeze(" ").split
        elf = line[0]
        dwarf = line[1]
        score = []
        @@elves[elf].preferences[dwarf] = score_translate(line[2])
        @@dwarves[dwarf].preferences[elf] = score_translate(line[3])
      end
    end
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

  def match_maker
    loop do
      #find elves that are unmarried and have still preferences left to propose to
      unmatched = @@elves.select {|key, elf| (elf.preferences.keys - elf.proposed_to).length > 0 && !elf.married}
      unmatched.each do |key, elf|
        unproposed = without(elf.preferences, elf.proposed_to)
        unless unproposed.empty?
          elf.propose_to(unproposed.key(unproposed.values.max), self)
        end
      end
      #end if no more matching needed
      if unmatched.length == 0
        break
      end
    end
  end

  #return preferences hash that excludes already proposed to keys
  def without(hash, keys)
    copy = hash.dup
    keys.each { |key| copy.delete(key) }
    copy
  end

  def print_result
    @@elves.each {|key, elf| p "#{elf.name} : #{elf.married_to}" if elf.married}
  end
end

edm = Edm.new
