class Material
  
  attr_accessor :code, :name

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.all
    @materials ||= [
      new({code: "C",  name: "carbon"}),
      new({code: "Fe", name: "iron"}),
      new({code: "Ni", name: "nickel"}),
      new({code: "P",  name: "phosphorus"}),
      new({code: "S",  name: "sulphur"}),
      new({code: "As", name: "arsenic"}),
      new({code: "Cr", name: "chromium"}),
      new({code: "Ge", name: "germanium"}),
      new({code: "Mn", name: "manganese"}),
      new({code: "Se", name: "selenium"}),
      new({code: "V",  name: "vanadium"}),
      new({code: "Zn", name: "zinc"}),
      new({code: "Zr", name: "zirconium"}),
      new({code: "Cd", name: "cadmium"}),
      new({code: "Hg", name: "mercury"}),
      new({code: "Mo", name: "molybdenum"}),
      new({code: "Nb", name: "niobium"}),
      new({code: "Sn", name: "tin"}),
      new({code: "W",  name: "tungsten"}),
      new({code: "Sb", name: "antimony"}),
      new({code: "Po", name: "polonium"}),
      new({code: "Ru", name: "ruthenium"}),
      new({code: "Tc", name: "technetium"}),
      new({code: "Te", name: "tellurium"}),
      new({code: "Y",  name: "yttrium"})
    ]
  end
end
