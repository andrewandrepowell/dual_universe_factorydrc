

local dump = require 'pl.pretty'.dump
require 'crafter'

local function refiner_subdesign(design, container_input, container_output, name)
  assert(type(name)=="string")
  assert(isinstance(design, Design.new()))
  assert(isinstance(container_input, Design.Container.new()))
  assert(isinstance(container_output, Design.Container.new()))
  local i0 = Design.Industry.new(refiner_m, pure_aluminum, name .. "pure_aluminum")
  local i1 = Design.Industry.new(refiner_m, pure_carbon, name .. "pure_carbon")
  local i2 = Design.Industry.new(refiner_m, pure_iron, name .. "pure_iron")
  local i3 = Design.Industry.new(refiner_m, pure_silicon, name .. "pure_silicon")
  Design.Container.add_ingredient(container_output, pure_hydrogen)
  Design.Container.add_ingredient(container_output, pure_oxygen)
  Design.connect(design, container_input, i0)
  Design.connect(design, container_input, i1)
  Design.connect(design, container_input, i2)
  Design.connect(design, container_input, i3)
  Design.connect(design, i0, container_output)
  Design.connect(design, i1, container_output)
  Design.connect(design, i2, container_output)
  Design.connect(design, i3, container_output)
end

local function smelter_subdesign(design, container_input, container_output, name)
  assert(type(name)=="string")
  assert(isinstance(container_input, Design.Container.new()))
  assert(isinstance(container_output, Design.Container.new()))
  local i_silumin = Design.Industry.new(smelter_m, silumin, name .. "_silumin")
  local i_steel = Design.Industry.new(smelter_m, steel, name .. "_steel")
  local i_al_fe_alloy = Design.Industry.new(smelter_m, al_fe_alloy, name .. "_al_fe_alloy")
  Design.connect(design, container_input, i_silumin)
  Design.connect(design, container_input, i_steel)
  Design.connect(design, container_input, i_al_fe_alloy)
  Design.connect(design, i_silumin, container_output)
  Design.connect(design, i_steel, container_output)
  Design.connect(design, i_al_fe_alloy, container_output)
end

local function smelter_chemical_subdesign(design, container_input, container_output, name)
  assert(type(name)=="string")
  assert(isinstance(container_input, Design.Container.new()))
  assert(isinstance(container_output, Design.Container.new()))
  local i_silumin = Design.Industry.new(smelter_m, silumin, name .. "_silumin")
  local i_steel = Design.Industry.new(smelter_m, steel, name .. "_steel")
  local i_al_fe_alloy = Design.Industry.new(smelter_m, al_fe_alloy, name .. "_al_fe_alloy")
  local i_polycarbonate_plastic = Design.Industry.new(chemical_industry_m, polycarbonate_plastic, name .. "_polycarbonate_plastic")
  Design.connect(design, container_input, i_silumin)
  Design.connect(design, container_input, i_steel)
  Design.connect(design, container_input, i_al_fe_alloy)
  Design.connect(design, container_input, i_polycarbonate_plastic)
  Design.connect(design, i_silumin, container_output)
  Design.connect(design, i_steel, container_output)
  Design.connect(design, i_al_fe_alloy, container_output)
  Design.connect(design, i_polycarbonate_plastic, container_output)
end 

local function industry_design()
  local design = Design.new()
  local i_smelter_m = Design.Industry.new(assembly_line_m, smelter_m, "smelter_m")
  local i_metalwork_industry_m = Design.Industry.new(assembly_line_m, metalwork_industry_m, "metalwork_industry_m")
  local i_chemical_industry_m = Design.Industry.new(assembly_line_m, chemical_industry_m, "chemical_industry_m")
  local i_refiner_m = Design.Industry.new(assembly_line_m,refiner_m,"refiner_m")
  local i_assembly_line_m = Design.Industry.new(assembly_line_s, assembly_line_m, "assembly_line_m")
  local i_basic_screw = Design.Industry.new(metalwork_industry_m, basic_screw, "basic_screw")
  local i_basic_mobile_panel_m = Design.Industry.new(metalwork_industry_m, basic_mobile_panel_m, "basic_mobile_panel_m")
  local i_basic_pipe = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_reinforced_frame_m = Design.Industry.new(metalwork_industry_m,basic_reinforced_frame_m,"basic_reinforced_frame_m")
  local i_basic_burner = Design.Industry.new(metalwork_industry_m,basic_burner,"basic_burner")
  local i_basic_chemical_container_m = Design.Industry.new(metalwork_industry_m, basic_chemical_container_m, "basic_chemical_container_m")
  local i_basic_power_system = Design.Industry.new(electronics_industry_m, basic_power_system, "basic_power_system")
  local i_basic_connector = Design.Industry.new(electronics_industry_m, basic_connector, "basic_connector")

  local c0 = Design.Container.new("c0")
  local c1 = Design.Container.new("c1")
  local c2 = Design.Container.new("c2")
  local c3 = Design.Container.new("c3")
  local c4 = Design.Container.new("c4")
  
  local t0 = Design.Transfer.new(basic_screw, "t0")
  
  Design.Container.add_ingredient(c0, bauxite)
  Design.Container.add_ingredient(c0, coal)
  Design.Container.add_ingredient(c0, hematite)
  Design.Container.add_ingredient(c0, quartz)
  
  refiner_subdesign(design, c0, c3, "refiner")
  smelter_chemical_subdesign(design, c3, c2, "smelter_chemical")
  Design.connect(design, t0, c2)
  Design.connect(design, c2, i_basic_screw)
  Design.connect(design, c2, i_basic_power_system)
  Design.connect(design, c2, i_basic_connector)
  Design.connect(design, c2, i_basic_mobile_panel_m)
  Design.connect(design, c2, i_basic_reinforced_frame_m)
  Design.connect(design, c2, i_basic_pipe)
  Design.connect(design, c2, i_basic_burner)
  Design.connect(design, c2, i_basic_chemical_container_m)
  
  Design.connect(design, i_basic_connector, c4)
  Design.connect(design, c4, i_basic_power_system)

  Design.connect(design, i_basic_power_system, c1)
  Design.connect(design, i_basic_screw, c1)
  Design.connect(design, i_basic_mobile_panel_m, c1)
  Design.connect(design, i_basic_reinforced_frame_m, c1)
  Design.connect(design, i_basic_pipe, c1)
  Design.connect(design, i_basic_burner, c1)
  Design.connect(design, i_basic_chemical_container_m, c1)
  Design.connect(design, c1, i_assembly_line_m)
  Design.connect(design, c1, i_chemical_industry_m)
  Design.connect(design, c1, i_metalwork_industry_m)
  Design.connect(design, c1, i_smelter_m)
  Design.connect(design, c1, i_refiner_m)
  Design.connect(design, c1, t0)

  Design.connect(design, i_assembly_line_m, c0) 
  Design.connect(design, i_chemical_industry_m, c0)  
  Design.connect(design, i_metalwork_industry_m, c0)
  Design.connect(design, i_smelter_m, c0)
  Design.connect(design, i_refiner_m, c0)
  
  Design.print_ingredients_in_containers(design)
  Design.check(design)
end

local function atmospheric_engine_m_design()
  local design = Design.new()
  local i_industry = Design.Industry.new(assembly_line_m, atmospheric_engine_m)
  local i_basic_screw = Design.Industry.new(metalwork_industry_m, basic_screw)
  local i_basic_injector = Design.Industry.new(_3d_printer_m, basic_injector)
  local i_polycarbonate_plastic = Design.Industry.new(chemical_industry_m, polycarbonate_plastic)
  local i_basic_combustion_chamber_m = Design.Industry.new(metalwork_industry_m, basic_combustion_chamber_m)
  local i_basic_pipe = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_reinforced_frame_m = Design.Industry.new(metalwork_industry_m, basic_reinforced_frame_m)
  
  local c0 = Design.Container.new("c0")
  local c1 = Design.Container.new("c1")
  local c2 = Design.Container.new("c2")
  local c3 = Design.Container.new("c3")
  local c4 = Design.Container.new("c4")
  local c5 = Design.Container.new("c5")
  
  local t0 = Design.Transfer.new(basic_screw, "t0")
  
  Design.Container.add_ingredient(c0, bauxite)
  Design.Container.add_ingredient(c0, coal)
  Design.Container.add_ingredient(c0, hematite)
  Design.Container.add_ingredient(c0, quartz)
  
  refiner_subdesign(design, c0, c3, "refiner")
  smelter_subdesign(design, c3, c2, "smelter")
  
  Design.connect(design, c1, t0)
  Design.connect(design, t0, c4)
  
  Design.connect(design, c3, i_polycarbonate_plastic)
  
  Design.connect(design, c2, i_basic_screw)
  Design.connect(design, c2, i_basic_combustion_chamber_m)
  Design.connect(design, c2, i_basic_pipe)
  Design.connect(design, c2, i_basic_reinforced_frame_m)
  
  Design.connect(design, i_basic_pipe, c4)
  Design.connect(design, i_polycarbonate_plastic, c4)
  Design.connect(design, c4, i_basic_injector)
  Design.connect(design, c4, i_basic_combustion_chamber_m)
  
  Design.connect(design, i_basic_reinforced_frame_m, c1)
  Design.connect(design, i_basic_combustion_chamber_m, c1)
  Design.connect(design, i_basic_screw, c1)
  Design.connect(design, i_basic_injector, c1)
  Design.connect(design, c1, i_industry)
  
  Design.connect(design, i_industry, c0)
  
  Design.print_ingredients_in_containers(design)
  Design.check(design)
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
  
  refiner_subdesign(design, c0, c3, "refiner")
  smelter_subdesign(design, c3, c2, "smelter")
  
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

local function mix_design0()
  local design = Design.new()
  local i_atmospheric_engine_m = Design.Industry.new(assembly_line_m, atmospheric_engine_m) --
  local i_transfer_unit = Design.Industry.new(assembly_line_l, transfer_unit)
  local i_basic_pipe0 = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_pipe1 = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_robotic_arm_l = Design.Industry.new(metalwork_industry_m, basic_robotic_arm_l)
  local i_basic_standard_frame_l = Design.Industry.new(metalwork_industry_m, basic_standard_frame_l)
  local i_basic_hydraulics = Design.Industry.new(metalwork_industry_m, basic_hydraulics)
  local i_basic_component = Design.Industry.new(electronics_industry_m, basic_component)
  local i_basic_screw = Design.Industry.new(metalwork_industry_m, basic_screw) --
  local i_basic_injector = Design.Industry.new(_3d_printer_m, basic_injector) --
  local i_polycarbonate_plastic = Design.Industry.new(chemical_industry_m, polycarbonate_plastic) --
  local i_basic_combustion_chamber_m = Design.Industry.new(metalwork_industry_m, basic_combustion_chamber_m) --
  local i_basic_reinforced_frame_m = Design.Industry.new(metalwork_industry_m, basic_reinforced_frame_m) --
  
  local t0 = Design.Transfer.new(basic_screw, "t0")
  
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
  
  refiner_subdesign(design, c0, c3, "refiner")
  smelter_subdesign(design, c3, c2, "smelter")
  
  Design.connect(design, c1, t0) --
  Design.connect(design, t0, c4) --
  
  Design.connect(design, c3, i_polycarbonate_plastic) --
  
  Design.connect(design, c2, i_basic_pipe0)
  Design.connect(design, c2, i_basic_pipe1)
  Design.connect(design, c2, i_basic_hydraulics)
  Design.connect(design, c2, i_basic_robotic_arm_l)
  Design.connect(design, c2, i_basic_component)
  Design.connect(design, c2, i_basic_standard_frame_l)
  Design.connect(design, c2, i_basic_screw) --
  Design.connect(design, c2, i_basic_combustion_chamber_m) --
  Design.connect(design, c2, i_basic_reinforced_frame_m) --
  
  Design.connect(design, i_basic_component, c5)
  Design.connect(design, c5, i_basic_robotic_arm_l)
  
  Design.connect(design, i_basic_pipe1, c4)
  Design.connect(design, i_polycarbonate_plastic, c4) --
  Design.connect(design, c4, i_basic_hydraulics)
  Design.connect(design, c4, i_basic_injector) --
  Design.connect(design, c4, i_basic_combustion_chamber_m) --
  
  Design.connect(design, i_basic_standard_frame_l, c1)
  Design.connect(design, i_basic_robotic_arm_l, c1)
  Design.connect(design, i_basic_pipe0, c1)
  Design.connect(design, i_basic_hydraulics, c1)
  Design.connect(design, i_basic_screw, c1) --
  Design.connect(design, i_basic_injector, c1) --
  Design.connect(design, i_basic_combustion_chamber_m, c1) --
  Design.connect(design, i_basic_reinforced_frame_m, c1) --
  Design.connect(design, c1, i_transfer_unit)
  Design.connect(design, c1, i_atmospheric_engine_m) --
  
  Design.connect(design, i_transfer_unit, c0)
  Design.connect(design, i_atmospheric_engine_m, c0) --
  
  Design.print_ingredients_in_containers(design)
  Design.check(design)
end

-- Produces adjustor_m, container_l, stabilizer_m
local function mix_design1()
  local design = Design.new()
  local i_hover_engine_m = Design.Industry.new(assembly_line_s, hover_engine_m)
  local i_container_l = Design.Industry.new(assembly_line_l, container_l)
  local i_atmospheric_airbrake_m = Design.Industry.new(assembly_line_s, atmospheric_airbrake_m)
  local i_basic_pipe = Design.Industry.new(metalwork_industry_m, basic_pipe)
  local i_basic_gaz_cylinder_s = Design.Industry.new(metalwork_industry_m, basic_gaz_cylinder_s)
  local i_basic_standard_frame_s = Design.Industry.new(metalwork_industry_m, basic_standard_frame_s)
  local i_basic_hydraulics = Design.Industry.new(metalwork_industry_m, basic_hydraulics)
  local i_basic_reinforced_frame_s = Design.Industry.new(metalwork_industry_m, basic_reinforced_frame_s)
  local i_basic_mobile_panel_s = Design.Industry.new(metalwork_industry_m, basic_mobile_panel_s)
  local i_basic_reinforced_frame_l = Design.Industry.new(metalwork_industry_m, basic_reinforced_frame_l)
  local i_basic_screw = Design.Industry.new(metalwork_industry_m, basic_screw)
  local i_basic_component = Design.Industry.new(electronics_industry_m, basic_component)
  local i_basic_injector = Design.Industry.new(_3d_printer_m, basic_injector)
  local i_polycarbonate_plastic = Design.Industry.new(chemical_industry_m, polycarbonate_plastic)

  local c0 = Design.Container.new("c0")
  local c1 = Design.Container.new("c1")
  local c2 = Design.Container.new("c2")
  local c3 = Design.Container.new("c3")
  local c4 = Design.Container.new("c4")
  
  local t0 = Design.Transfer.new(basic_screw)
  local t1 = Design.Transfer.new(basic_pipe)
  
  Design.Container.add_ingredient(c0, bauxite)
  Design.Container.add_ingredient(c0, coal)
  Design.Container.add_ingredient(c0, hematite)
  Design.Container.add_ingredient(c0, quartz)
  
  refiner_subdesign(design, c0, c3, "refiner")
  smelter_subdesign(design, c3, c2, "smelter")
  
  Design.connect(design, t1, c2)
  Design.connect(design, c2, i_basic_pipe)
  Design.connect(design, c2, i_basic_screw)
  Design.connect(design, c2, i_basic_gaz_cylinder_s)
  Design.connect(design, c2, i_basic_standard_frame_s)
  Design.connect(design, c2, i_basic_component)
  Design.connect(design, c2, i_basic_hydraulics)
  Design.connect(design, c2, i_basic_reinforced_frame_s)
  Design.connect(design, c2, i_basic_mobile_panel_s)
  Design.connect(design, c2, i_basic_reinforced_frame_l)
  
  Design.connect(design, c3, i_polycarbonate_plastic)
  
  Design.connect(design, t0, c4)
  Design.connect(design, i_polycarbonate_plastic, c4)
  Design.connect(design, c4, i_basic_injector)
  Design.connect(design, c4, i_basic_gaz_cylinder_s)
  Design.connect(design, c4, i_basic_mobile_panel_s)
  
  Design.connect(design, i_basic_screw, c1)
  Design.connect(design, i_basic_injector, c1)
  Design.connect(design, i_basic_pipe, c1)
  Design.connect(design, i_basic_gaz_cylinder_s, c1)
  Design.connect(design, i_basic_standard_frame_s, c1)
  Design.connect(design, i_basic_component, c1)
  Design.connect(design, i_basic_hydraulics, c1)
  Design.connect(design, i_basic_reinforced_frame_s, c1)
  Design.connect(design, i_basic_mobile_panel_s, c1)
  Design.connect(design, i_basic_reinforced_frame_l, c1)
  Design.connect(design, c1, i_hover_engine_m)
  Design.connect(design, c1, i_container_l)
  Design.connect(design, c1, i_atmospheric_airbrake_m)
  Design.connect(design, c1, t0)
  Design.connect(design, c1, t1)
  
  Design.connect(design, i_hover_engine_m, c0)
  Design.connect(design, i_container_l, c0)
  Design.connect(design, i_atmospheric_airbrake_m, c0)
  
  Design.print_ingredients_in_containers(design)
  Design.check(design)
end

--mix_design0()
--mix_design1()
industry_design()

--dump(Item.production_amount(stabilizer_m, true))
--dump(Item.production_amount(adjustor_m, true))
--dump(Item.production_amount(container_l, true))



