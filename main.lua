

local dump = require 'pl.pretty'.dump
require 'crafter'

--local Item = require 'crafter'.Item
--print(require 'crafter')

-- Produce the production values
--dump(item_ingredients(metalwork_industry_m, true))
--dump(Item.production_tree(metalwork_industry_m, true))

--dump(item_production_amount(basic_reinforced_frame_m, true))

--dump(item_production_amount(smelter_m, true))
--dump(item_production_amount(metalwork_industry_m, true))
--dump(item_production_amount(electronics_industry_m, true))
--dump(item_production_amount(assembly_line_m, true))

--dump(item_production_amount(smelter_m, true))


--dump(Item.production_amount(_3d_printer_m, true))
--dump(item_production_tree(refiner_m, true))

--print(isinstance(Item.new(), Container(Item.new())))

-- Implements the refiner design.
local function refiner_subdesign(design, container_input, container_output)
  assert(isinstance(design, Design.new()))
  assert(isinstance(container_input, Design.Container.new()))
  local i0 = Design.Industry.new(refiner_m, pure_aluminum)
  local i1 = Design.Industry.new(refiner_m, pure_carbon)
  local i2 = Design.Industry.new(refiner_m, pure_iron)
  local i3 = Design.Industry.new(refiner_m, pure_silicon)
  Design.Container.add_ingredient(container_output, pure_hydrogen)
  Design.connect(design, container_input, i0)
  Design.connect(design, container_input, i1)
  Design.connect(design, container_input, i2)
  Design.connect(design, container_input, i3)
  Design.connect(design, i0, container_output)
  Design.connect(design, i1, container_output)
  Design.connect(design, i2, container_output)
  Design.connect(design, i3, container_output)
end


local function transfer_unit_design()
  local design = Design.new()
  
  local i_transfer_unit = Design.Industry.new(assembly_line_l, transfer_unit)
  local i_basic_pipe0 = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_pipe1 = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_robotic_arm_l = Design.Industry.new(metalwork_industry_m, basic_robotic_arm_l)
  local i_basic_standard_frame_l = Design.Industry.new(metalwork_industry_m, basic_standard_frame_l)
  local i_basic_hydraulics = Design.Industry.new(metalwork_industry_m, basic_hydraulics)
  local i_basic_component = Design.Industry.new(electronics_industry_m, basic_component)
  local i_silumin = Design.Industry.new(smelter_m, silumin)
  local i_steel = Design.Industry.new(smelter_m, steel)
  local i_al_fe_alloy = Design.Industry.new(smelter_m, al_fe_alloy)
  
  local c0 = Design.Container.new("c0")
  local c1 = Design.Container.new("c1")
  local c2 = Design.Container.new("c2")
  local c3 = Design.Container.new("c3")
  local c4 = Design.Container.new("c4")
  local c5 = Design.Container.new("c5")
  
  Design.Container.add_ingredient(c0, bauxite)
  Design.Container.add_ingredient(c0, coal)
  Design.Container.add_ingredient(c0, hematite)
  Design.Container.add_ingredient(c0, quartz)
  refiner_subdesign(design, c0, c3)
  
  Design.connect(design, c3, i_silumin)
  Design.connect(design, c3, i_steel)
  Design.connect(design, c3, i_al_fe_alloy)
  
  Design.connect(design, i_silumin, c2)
  Design.connect(design, i_steel, c2)
  Design.connect(design, i_al_fe_alloy, c2)
  Design.connect(design, c2, i_basic_pipe0)
  Design.connect(design, c2, i_basic_pipe1)
  Design.connect(design, c2, i_basic_hydraulics)
  Design.connect(design, c2, i_basic_robotic_arm_l)
  Design.connect(design, c2, i_basic_component)
  Design.connect(design, c2, i_basic_standard_frame_l)
  
  Design.connect(design, i_basic_component, c5)
  Design.connect(design, c5, i_basic_robotic_arm_l)
  
  Design.connect(design, i_basic_pipe1, c4)
  Design.connect(design, c4, i_basic_hydraulics)
  
  Design.connect(design, i_basic_standard_frame_l, c1)
  Design.connect(design, i_basic_robotic_arm_l, c1)
  Design.connect(design, i_basic_pipe0, c1)
  Design.connect(design, i_basic_hydraulics, c1)
  Design.connect(design, c1, i_transfer_unit)
  
  Design.connect(design, i_transfer_unit, c0)
  
  Design.print_ingredients_in_containers(design)
  Design.check(design)
end

-- Implements and checks full design for given ingredients.
local function full_design(assembly_line_m0_ingredient, 
                           assembly_line_m1_ingredient)
                           
  local d = Design.new()
  local i_assembly_m0 = Design.Industry.new(assembly_line_m, assembly_line_m0_ingredient)
  local i_assembly_m1 = Design.Industry.new(assembly_line_m, assembly_line_m1_ingredient)
  local i_polycarbonate_plastic = Design.Industry.new(chemical_industry_m, polycarbonate_plastic)
  local i_basic_pipe = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_reinforced_frame_m = Design.Industry.new(metalwork_industry_m, basic_reinforced_frame_m)
  local i_basic_robotic_arm_m = Design.Industry.new(metalwork_industry_m, basic_robotic_arm_m)
  local i_basic_screw = Design.Industry.new(metalwork_industry_m, basic_screw)
  local i_basic_combustion_chamber_m = Design.Industry.new(metalwork_industry_m, basic_combustion_chamber_m)
  local i_basic_mobile_panel_m = Design.Industry.new(metalwork_industry_m, basic_mobile_panel_m)
  local i_basic_hydraulics = Design.Industry.new(metalwork_industry_m, basic_hydraulics)
  local i_basic_burner = Design.Industry.new(metalwork_industry_m, basic_burner)
  local i_basic_injector = Design.Industry.new(_3d_printer_m, basic_injector)
  local i_basic_component = Design.Industry.new(electronics_industry_m, basic_component)
  local i_basic_power_system = Design.Industry.new(electronics_industry_m, basic_power_system)
  local i_basic_connector = Design.Industry.new(electronics_industry_m, basic_connector)
  local i_al_fe_alloy = Design.Industry.new(smelter_m, al_fe_alloy)
  local i_silumin = Design.Industry.new(smelter_m, silumin)
  local i_steel0 = Design.Industry.new(smelter_m, steel)
  
  local c0 = Design.Container.new("c0")
  local c1 = Design.Container.new("c1")
  local c2 = Design.Container.new("c2")
  local c6 = Design.Container.new("c6")
  
  Design.Container.add_ingredient(c0, bauxite)
  Design.Container.add_ingredient(c0, coal)
  Design.Container.add_ingredient(c0, hematite)
  Design.Container.add_ingredient(c0, quartz)
  
  local c4 = refiner_subdesign(d, c0)
  Design.connect(d, c4, i_polycarbonate_plastic)
  Design.connect(d, c4, i_silumin)
  Design.connect(d, c4, i_al_fe_alloy)
  Design.connect(d, c4, i_steel0)
  
  Design.connect(d, i_polycarbonate_plastic, c2)
  Design.connect(d, i_silumin, c2)
  Design.connect(d, i_al_fe_alloy, c2)
  Design.connect(d, i_steel0, c2)
  Design.connect(d, c2, i_basic_reinforced_frame_m)
  Design.connect(d, c2, i_basic_robotic_arm_m)
  Design.connect(d, c2, i_basic_component)
  Design.connect(d, c2, i_basic_pipe)
  Design.connect(d, c2, i_basic_screw)
  Design.connect(d, c2, i_basic_injector)
  Design.connect(d, c2, i_basic_combustion_chamber_m)
  Design.connect(d, c2, i_basic_mobile_panel_m)
  Design.connect(d, c2, i_basic_power_system)
  Design.connect(d, c2, i_basic_connector)
  
  Design.connect(d, i_basic_connector, c6)
  Design.connect(d, i_basic_pipe, c6)
  Design.connect(d, i_basic_screw, c6)
  Design.connect(d, i_basic_component, c6)
  Design.connect(d, c6, i_basic_robotic_arm_m)
  Design.connect(d, c6, i_basic_injector)
  Design.connect(d, c6, i_assembly_m0)
  Design.connect(d, c6, i_assembly_m1)
  Design.connect(d, c6, i_basic_combustion_chamber_m)
  Design.connect(d, c6, i_basic_mobile_panel_m)
  Design.connect(d, c6, i_basic_power_system)
  
  Design.connect(d, i_basic_mobile_panel_m, c1)
  Design.connect(d, i_basic_power_system, c1)
  Design.connect(d, i_basic_combustion_chamber_m, c1)
  Design.connect(d, i_basic_injector, c1)
  Design.connect(d, i_basic_robotic_arm_m, c1)
  Design.connect(d, i_basic_reinforced_frame_m, c1)
  Design.connect(d, c1, i_assembly_m0)
  Design.connect(d, c1, i_assembly_m1)
  
  Design.connect(d, i_assembly_m0, c0)
  Design.connect(d, i_assembly_m1, c0)
  
  Design.print_ingredients_in_containers(d)
  Design.check(d)
 
end

--dump(Item.production_tree(metalwork_industry_m, true))
--dump(Item.production_amount(metalwork_industry_m, true))

transfer_unit_design()

-- refiner_m
-- metalwork_industry_m
-- _3d_printer_m
--full_design(_3d_printer_m, _3d_printer_m)


