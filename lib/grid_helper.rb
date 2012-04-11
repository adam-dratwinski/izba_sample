class GridBuilder
  attr_accessor :model, :search, :columns 

  def initialize(model, search = nil)
    self.model = model
    self.search = search
    self.columns = []
  end

  def column(column, &block)
    self.columns.push(:column => column, :block => block)
  end

  def actions &block
    self.columns.push(:block => block)
  end
end
