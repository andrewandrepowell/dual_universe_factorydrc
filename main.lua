

local dump = require 'pl.pretty'.dump
require 'crafter'

local function contained_industry(design, production, ingredient, name)

  local industry = Design.Industry.new(production, ingredient, "i_" .. name)
  local container = Design.Container.new("c_" .. name)
  
  Design.connect(design,industry,container)
  
  return {industry=industry, container=container}
end

local function refiner_subdesign(design, name)
  
  local i_pure_aluminum = contained_industry(design, refiner_m, pure_aluminum, name .. "_pure_aluminum")
  local i_pure_carbon = contained_industry(design, refiner_m, pure_carbon, name .. "_pure_carbon")
  local i_pure_iron = contained_industry(design, refiner_m, pure_iron, name .. "_pure_iron")
  local i_pure_silicon = contained_industry(design, refiner_m, pure_silicon, name .. "_pure_silicon")
  local i_pure_sodium = contained_industry(design, refiner_m,pure_sodium, name .. "_pure_sodium")
  local i_pure_calcium = contained_industry(design, refiner_m,pure_calcium, name .. "_pure_calcium")
  local i_pure_copper = contained_industry(design, refiner_m,pure_copper, name .. "_pure_copper")
  
  local c_bauxite = Design.Container.new(name .. "_bauxite")
  local c_coal = Design.Container.new(name .. "_coal")
  local c_hematite = Design.Container.new(name .. "_hematite")
  local c_quartz = Design.Container.new(name .. "_quartz")
  local c_natron = Design.Container.new(name .. "_natron")
  local c_limestone = Design.Container.new(name .. "_limestone")
  local c_malachite = Design.Container.new(name .. "_malachite")
  
  Design.Container.add_ingredient(c_bauxite, bauxite)
  Design.Container.add_ingredient(c_coal, coal)
  Design.Container.add_ingredient(c_hematite, hematite)
  Design.Container.add_ingredient(c_quartz, quartz)
  Design.Container.add_ingredient(c_natron, natron)
  Design.Container.add_ingredient(c_limestone, limestone)
  Design.Container.add_ingredient(c_malachite, malachite)
  
  Design.connect(design, c_bauxite, i_pure_aluminum.industry)
  Design.connect(design, c_coal, i_pure_carbon.industry)
  Design.connect(design, c_hematite, i_pure_iron.industry)
  Design.connect(design, c_quartz, i_pure_silicon.industry)
  Design.connect(design, c_natron, i_pure_sodium.industry)
  Design.connect(design, c_limestone, i_pure_calcium.industry)
  Design.connect(design, c_malachite, i_pure_copper.industry)
  
  Design.Container.add_ingredient(i_pure_aluminum.container, pure_hydrogen)
  Design.Container.add_ingredient(i_pure_carbon.container, pure_oxygen)
  Design.Container.add_ingredient(i_pure_carbon.container, pure_hydrogen)
  
  return i_pure_aluminum.container, i_pure_carbon.container, 
    i_pure_iron.container, i_pure_silicon.container, i_pure_sodium.container,
    i_pure_calcium.container, i_pure_copper.container
end

local function smelter_chemical_subdesign(design, 
    c_pure_aluminum, c_pure_carbon, c_pure_iron, c_pure_silicon, 
    c_pure_sodium, c_pure_copper, c_pure_calcium, name)
  
  local i_silumin = contained_industry(design, smelter_m, silumin, name .. "_silumin")
  local i_steel = contained_industry(design, smelter_m, steel, name .. "_steel")
  local i_al_fe_alloy = contained_industry(design, smelter_m, al_fe_alloy, name .. "_al_fe_alloy")
  local i_calcium_reinforced_copper = contained_industry(design, smelter_m, calcium_reinforced_copper, name .. "_calcium_reinforced_copper")
  local i_polycarbonate_plastic = contained_industry(design, chemical_industry_m, polycarbonate_plastic, name .. "_polycarbonate_plastic")
  local i_polycalcite_plastic = contained_industry(design, chemical_industry_m, polycalcite_plastic, name .. "_polycalcite_plastic")
  
  Design.connect(design, c_pure_aluminum, i_silumin.industry)
  Design.connect(design, c_pure_silicon, i_silumin.industry)
  
  Design.connect(design, c_pure_iron, i_steel.industry)
  Design.connect(design, c_pure_carbon, i_steel.industry)
  
  Design.connect(design, c_pure_aluminum, i_al_fe_alloy.industry)
  Design.connect(design, c_pure_iron, i_al_fe_alloy.industry)
  
  Design.connect(design, c_pure_copper, i_calcium_reinforced_copper.industry)
  Design.connect(design, c_pure_calcium, i_calcium_reinforced_copper.industry)
  
  Design.connect(design, c_pure_carbon, i_polycarbonate_plastic.industry)
  Design.connect(design, c_pure_aluminum, i_polycarbonate_plastic.industry)
  
  Design.connect(design, c_pure_calcium, i_polycalcite_plastic.industry)
  Design.connect(design, c_pure_carbon, i_polycalcite_plastic.industry)
  Design.connect(design, c_pure_aluminum, i_polycalcite_plastic.industry)
 
  return i_silumin.container, i_steel.container, i_al_fe_alloy.container, 
    i_calcium_reinforced_copper.container, i_polycarbonate_plastic.container, 
    i_polycalcite_plastic.container
end 

local function industry_design()
  local design = Design.new()
  local i_screen_m = contained_industry(design, assembly_line_xs,screen_m,"screen_m")
  local i_basic_component = contained_industry(design, electronics_industry_m, basic_component, "basic_component")
  local i_basic_electronics = contained_industry(design, electronics_industry_m, basic_electronics, "basic_electronics")
  local i_uncommon_component = contained_industry(design, electronics_industry_m, uncommon_component, "uncommon_component")
  local i_uncommon_electronics = contained_industry(design, electronics_industry_m, uncommon_electronics, "uncommon_electronics")
  local i_uncommon_screen_xs = contained_industry(design, _3d_printer_m, uncommon_screen_xs, "uncommon_screen_xs")
  local i_uncommon_casing_xs = contained_industry(design, _3d_printer_m, uncommon_casing_xs, "uncommon_casing_xs")
  local i_basic_led = contained_industry(design, glass_furnace_m, basic_led, "basic_led")
  local i_uncommon_led = contained_industry(design, glass_furnace_m,uncommon_led,"uncommon_led")
  local i_glass = contained_industry(design, glass_furnace_m, glass, "glass")
  local i_advanced_glass = contained_industry(design, glass_furnace_m,advanced_glass,"advanced_glass")
  
  local t0 = Design.Transfer.new(uncommon_casing_xs, "t0")
  local t1 = Design.Transfer.new(uncommon_electronics, "t1")
  
  local c_pure_aluminum, c_pure_carbon, c_pure_iron, c_pure_silicon, c_pure_sodium,
    c_pure_calcium, c_pure_copper = refiner_subdesign(design, "refiners")
  local c_silumin, c_steel, c_al_fe_alloy, c_calcium_reinforced_copper, c_polycarbonate_plastic, 
    c_polycalcite_plastic = smelter_chemical_subdesign(design, 
    c_pure_aluminum, c_pure_carbon, c_pure_iron, c_pure_silicon, 
    c_pure_sodium, c_pure_copper, c_pure_calcium, "smelters_chems")
    
  Design.connect(design, c_pure_carbon, i_advanced_glass.industry)  
  Design.connect(design, c_pure_silicon, i_advanced_glass.industry)  
  Design.connect(design, c_pure_calcium, i_advanced_glass.industry)  
  Design.connect(design, c_pure_sodium, i_advanced_glass.industry)  
    
  Design.connect(design, c_pure_carbon, i_glass.industry)
  Design.connect(design, c_pure_silicon, i_glass.industry)
    
  Design.connect(design, i_advanced_glass.container, i_uncommon_led.industry)
  Design.connect(design, i_glass.container, i_uncommon_led.industry)
    
  Design.connect(design, i_glass.container, i_basic_led.industry)
    
  Design.connect(design, c_polycalcite_plastic, i_uncommon_casing_xs.industry)
  Design.connect(design, c_polycarbonate_plastic, i_uncommon_casing_xs.industry)
    
  Design.connect(design, c_polycarbonate_plastic, i_basic_electronics.industry)
  Design.connect(design, i_basic_component.container, i_basic_electronics.industry)
    
  Design.connect(design, i_basic_led.container, i_uncommon_screen_xs.industry)
  Design.connect(design, i_basic_electronics.container, i_uncommon_screen_xs.industry)
  Design.connect(design, c_polycalcite_plastic, i_uncommon_screen_xs.industry)
  Design.connect(design, i_uncommon_led.container, i_uncommon_screen_xs.industry)
  Design.connect(design, i_uncommon_electronics.container, t1)
  Design.connect(design, t1, i_uncommon_led.container)
    
  Design.connect(design, c_polycarbonate_plastic, i_uncommon_electronics.industry)
  Design.connect(design, i_basic_component.container, i_uncommon_electronics.industry)
  Design.connect(design, c_polycalcite_plastic, i_uncommon_electronics.industry)
  
  Design.connect(design, c_al_fe_alloy, i_uncommon_component.industry)
  Design.connect(design, c_calcium_reinforced_copper, i_uncommon_component.industry)
  
  Design.connect(design, c_al_fe_alloy, i_basic_component.industry)
  
  Design.connect(design, i_uncommon_component.container, i_screen_m.industry)
  Design.connect(design, i_basic_component.container, i_screen_m.industry)
  Design.connect(design, i_uncommon_electronics.container, i_screen_m.industry)
  Design.connect(design, i_uncommon_screen_xs.container, i_screen_m.industry)
  Design.connect(design, i_uncommon_casing_xs.container, t0)
  Design.connect(design, t0, i_uncommon_screen_xs.container)
  
  Design.print_containers(design) 
  Design.check(design)

  Design.print_statistics(design)

end

local function declarations()
  local i_smelter_m = contained_industry(design, assembly_line_m, smelter_m, "smelter_m")
  local i_metalwork_industry_m = contained_industry(design, assembly_line_m, metalwork_industry_m, "metalwork_industry_m")
  local i_chemical_industry_m = contained_industry(design, assembly_line_m, chemical_industry_m, "chemical_industry_m")
  local i_electronics_industry_m = contained_industry(design, assembly_line_m, electronics_industry_m, "electronics_industry_m")
  local i_refiner_m = contained_industry(design, assembly_line_m,refiner_m,"refiner_m")
  local i_assembly_line_m = contained_industry(design, assembly_line_s, assembly_line_m, "assembly_line_m")
  local i_glass_furnace_m = contained_industry(design, assembly_line_m, glass_furnace_m, "glass_furnace_m")
  local i_container_s = contained_industry(design, assembly_line_m,container_s,"container_s")
  local i_3d_printer_m = contained_industry(design, assembly_line_m, _3d_printer_m, "3d_printer_m")
  local i_screen_m = contained_industry(design, assembly_line_xs,screen_m,"screen_m")
  local i_basic_screw = contained_industry(design, metalwork_industry_m, basic_screw, "basic_screw")
  local i_basic_mobile_panel_m = contained_industry(design, metalwork_industry_m, basic_mobile_panel_m, "basic_mobile_panel_m")
  local i_basic_reinforced_frame_m = contained_industry(design, metalwork_industry_m,basic_reinforced_frame_m,"basic_reinforced_frame_m")
  local i_basic_burner = contained_industry(design, metalwork_industry_m,basic_burner,"basic_burner")
  local i_basic_chemical_container_m = contained_industry(design, metalwork_industry_m, basic_chemical_container_m, "basic_chemical_container_m")
  local i_basic_robotic_arm_m = contained_industry(design, metalwork_industry_m, basic_robotic_arm_m, "basic_robotic_arm_m")
  local i_basic_pipe = contained_industry(design, metalwork_industry_m,basic_pipe,"basic_pipe")
  local i_basic_hydraulics = contained_industry(design, metalwork_industry_m,basic_hydraulics,"basic_hydraulics")
  local i_basic_power_system = contained_industry(design, electronics_industry_m, basic_power_system, "basic_power_system")
  local i_basic_connector = contained_industry(design, electronics_industry_m, basic_connector, "basic_connector")
  local i_basic_component = contained_industry(design, electronics_industry_m, basic_component, "basic_component")
  local i_basic_electronics = contained_industry(design, electronics_industry_m, basic_electronics, "basic_electronics")
  local i_uncommon_component = contained_industry(design, electronics_industry_m, uncommon_component, "uncommon_component")
  local i_uncommon_electronics = contained_industry(design, electronics_industry_m, uncommon_electronics, "uncommon_electronics")
  local i_basic_power_transformer_m = contained_industry(design, electronics_industry_m,basic_power_transformer_m,"basic_power_transformer_m")
  local i_uncommon_screen_xs = contained_industry(design, _3d_printer_m, uncommon_screen_xs, "uncommon_screen_xs")
  local i_basic_injector = contained_industry(design, _3d_printer_m, basic_injector, "basic_injector")
  local i_basic_led = contained_industry(design, glass_furnace_m, basic_led, "basic_led")
  local i_glass = contained_industry(design, glass_furnace_m, glass, "glass")
  local i_uncommon_led = contained_industry(design, glass_furnace_m,uncommon_led,"uncommon_led")
  local i_advanced_glass = contained_industry(design, glass_furnace_m,advanced_glass,"advanced_glass")
  local i_uncommon_casing_xs = contained_industry(design, _3d_printer_m, uncommon_casing_xs, "uncommon_casing_xs")
end


industry_design()




