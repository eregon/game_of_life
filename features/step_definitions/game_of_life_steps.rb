def table2state table
  table.raw.map { |row| row.map { |cell| cell.tr('x.','10').to_i } }
end

Given /^the following setup$/ do |table|
  @game = GameOfLife.new table2state(table)
end

When /^I evolve the board$/ do
  @game.evolve
end

Then /^the center cell should be dead$/ do
  @game[@game.width/2, @game.height/2].should == 0
end

Then /^the center cell should be alive$/ do
  @game[@game.width/2, @game.height/2].should == 1
end

Then /^I should see the following board$/ do |table|
  @game.state.should == table2state(table)
end

