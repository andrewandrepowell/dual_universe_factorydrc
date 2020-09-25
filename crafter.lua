--
Item = {

  -- Create a new Item.
  new = function(name)
    name = name or "none"
    assert(type(name)=="string")
    return {
      name            = name,
      ingredients     = false,
      produced        = false,
      production_list = false,
    }
  end,
  
  -- Traverse through an Item's ingredients.
  traverse = function(item)
    assert(isinstance(item, Item.new()))
    local table = {}
    local function traverse(item) 
      table[#table+1] = item
      if item.ingredients == false then
        return
      end 
      for index, ingredients_amount in pairs(item.ingredients) do
        traverse(ingredients_amount[1])
      end 
    end
    traverse(item)
    return table
  end,
  
  -- Retreive a set of all the ingredients.
  ingredients = function (item, name_enable)
    -- First determine the set of ingredients.
    local table = {}
    for _, ingredients in pairs(Item.traverse(item)) do
      if table[ingredients]==nil then
        table[ingredients] = 0
      end
    end
    -- Next, determine the total amounts needed.
    local function traverse(item, amount_needed) 
      if item.ingredients == false then
        return
      end 
      for i, ingredient_amount in pairs(item.ingredients) do
        table[ingredient_amount[1]] = table[ingredient_amount[1]]+ingredient_amount[2]*amount_needed
        traverse(ingredient_amount[1], ingredient_amount[2])
      end 
    end
    table[item] = 1
    traverse(item, 1)
    -- Change the table references to names if specified.
    name_enable = name_enable or false
    assert(type(name_enable)=="boolean")
    if name_enable then
      local table_name = {}
      for ingredient, amount in pairs(table) do
        table_name[ingredient.name] = amount
      end
      return table_name
    end 
    return table
  end,
  
  -- Produce an empty production table.
  production = function(item) 
    -- First determine the industry set.
    local table = {}
    local table_raw = {}
    local ingredients = Item.traverse(item)
    for _, ingredient in pairs(ingredients) do
      if ingredient.production_list ~= false then
        local production = ingredient.production_list[1] -- defaults to the first industry.
        table[production] = {}
      else
        table_raw[ingredient] = true
      end
    end
    -- Determine the ingredients that need to be produced by the industries.
    for _, ingredient in pairs(ingredients) do
      if ingredient.production_list ~= false then
        local production = ingredient.production_list[1]
        table[production][ingredient] = true
      end
    end
    -- Return the production table.
    local production_table = {table, table_raw}
    return production_table
  end,
  
  -- Produce the production table with the ingredient amounts.
  production_amount = function(item, name_enable)
    local production_table = Item.production(item)
    -- Determine the ingredient amounts needed to be produced.
    local ingredients_amounts = Item.ingredients(item)
    for production, ingredients in pairs(production_table[1]) do
      for ingredient, _ in pairs(ingredients) do
        production_table[1][production][ingredient] = ingredients_amounts[ingredient]
      end
    end
    for ingredient, _ in pairs(production_table[2]) do
      production_table[2][ingredient] = ingredients_amounts[ingredient]
    end
    -- Change the table references to names if specified.
    name_enable = name_enable or false
    assert(type(name_enable)=="boolean")
    if name_enable then
      local table_name = {{}, {}}
      for production, ingredients in pairs(production_table[1]) do
        table_name[1][production.name] = {}
        for ingredient, amount  in pairs(ingredients) do
          table_name[1][production.name][ingredient.name] = amount
        end
      end
      for ingredient, amount in pairs(production_table[2]) do
        table_name[2][ingredient.name] = amount
      end
      return table_name
    end 
    return production_table
  end,
  
  production_tree = function(item, name_enable)
    -- Generate node table for each production and ingredient pair in
    -- the production table.
    local production_table = Item.production(item)
    for production, ingredients in pairs(production_table[1]) do
      for ingredient, _ in pairs(ingredients) do
        local node_table = {}
        local ingredients0 = ingredient.ingredients
        for _, ingredient_amount0 in pairs(ingredients0) do
          local ingredient0 = ingredient_amount0[1]
          local production0 = false
          if ingredient0.production_list~=false then
           production0 = ingredient0.production_list[1]
          end
          node_table[#node_table+1] = {production0, ingredient0}
        end
        production_table[1][production][ingredient] = node_table
      end
    end
    -- Change the table references to names if specified.
    name_enable = name_enable or false
    assert(type(name_enable)=="boolean")
    if name_enable then
      local table_name = {{}, {}}
      for production, ingredients in pairs(production_table[1]) do
        table_name[1][production.name] = {}
        for ingredient, node_table  in pairs(ingredients) do
          table_name[1][production.name][ingredient.name] = {}
          for index, production_ingredient in pairs(node_table) do
            local production_name = false
            if production_ingredient[1] then
              production_name = production_ingredient[1].name
            end
            table_name[1][production.name][ingredient.name][index] = {
              production_name, 
              production_ingredient[2].name}
          end
        end
      end
      for ingredient, amount in pairs(production_table[2]) do
        table_name[2][ingredient.name] = amount
      end
      return table_name
    end 
    return production_table
  end
}

Design = {

  Container = {
  
    MAX_CONNECTIONS = 10,
    
    new = function(name)
      if name~=nil then
        assert(type(name)=="string")
      end
      return {
        name        = name or "no_name",
        ingredients = {},
        inputs      = {},
        outputs     = {}
      }
    end,
    
    add_ingredient = function(container, ingredient)
      assert(isinstance(container, Design.Container.new()))
      assert(isinstance(ingredient, Item.new()))
      if not hasvalue(container.ingredients, ingredient) then
        container.ingredients[#container.ingredients+1] = ingredient
      end
    end,
    
    print_ingredients = function(container)
      assert(isinstance(container, Design.Container.new()))
      for _, ingredient in pairs(container.ingredients) do
        print(container.name .. ": ingredient=" .. ingredient.name)
      end
    end,
    
    print_inputs = function(container)
      assert(isinstance(container, Design.Container.new()))
      for _, input in pairs(container.inputs) do
        local msg = container.name .. ": input=" .. input.name
        if isinstance(input, Design.Industry.new()) then
          msg = msg .. ", production=" .. input.production.name
        end
        print(msg)
      end
    end,
    
    print_outputs = function(container)
      assert(isinstance(container, Design.Container.new()))
      for _, output in pairs(container.outputs) do
        local msg = container.name .. ": output=" .. output.name
        if isinstance(output, Design.Industry.new()) then
          msg = msg .. ", production=" .. output.production.name
        end
        print(msg)
      end
    end,
    
    print = function(container)
      Design.Container.print_ingredients(container)
      Design.Container.print_inputs(container)
      Design.Container.print_outputs(container)
    end, 
  },
  
  Transfer = {
  
    MAX_INPUTS = 7,
  
    new = function(ingredient, name)
      if ingredient~=nil then
        assert(isinstance(ingredient, Item.new()))
      end
      if name~=nil then
        assert(type(name)=="string")
      end
      return {
        name       = name or "no_name",
        ingredient = ingredient or false,
        inputs     = {},
        output     = false,
        transfer   = false,
      }
    end,
  
  },
  
  Industry = {
  
    MAX_INPUTS = 7,
    
    new = function(production, ingredient, name)
      if ingredient~=nil or production~=nil then
        assert(isinstance(production, Item.new()))
        assert(isinstance(ingredient, Item.new()))
        assert(hasvalue(ingredient.production_list, production), "ingredient not associated with production")
      end
      if name~= nil then
        assert(type(name)=="string")
      end
      return {
        name       = name or "no_name",
        production = production or false,
        ingredient = ingredient or false,
        inputs     = {},
        output     = false
      }
    end,
  },
  
  new = function()
    return {
      nodes = {}
    }
  end,
  
  connect = function(design, obj0, obj1)
    assert(isinstance(design, Design.new()))
    -- Container connected to Industry.
    if isinstance(obj0, Design.Container.new()) and isinstance(obj1, Design.Industry.new()) then
      -- Verify connections.
      assert((#obj0.outputs+#obj0.inputs)<Design.Container.MAX_CONNECTIONS, obj0.name .. " has too many connections")
      assert(#obj1.inputs<Design.Industry.MAX_INPUTS, obj1.name .. " has too many inputs")
      assert(not hasvalue(obj0.outputs, obj1), obj0.name .. " is already connected to " .. obj1.name)
      -- Perform connections.
      obj0.outputs[#obj0.outputs+1] = obj1
      obj1.inputs[#obj1.inputs+1] = obj0
    -- Industry connected to Container.
    elseif isinstance(obj0, Design.Industry.new()) and isinstance(obj1, Design.Container.new()) then
      -- Verify connections.
      assert(obj0.output==false, obj0.name .. " has an output set")
      assert((#obj1.inputs+#obj1.outputs)<Design.Container.MAX_CONNECTIONS, obj1.name .. " has too many connections")
      assert(obj0.output~=obj1, obj0.name .. " is already connected to " .. obj1.name)
      -- Perform connections.
      obj0.output = obj1
      obj1.inputs[#obj1.inputs+1] = obj0
      -- Update Container.
      Design.Container.add_ingredient(obj1, obj0.ingredient)
    -- Container connected to Transfer.
    elseif isinstance(obj0, Design.Container.new()) and isinstance(obj1, Design.Transfer.new()) then
      -- Verify connections.
      assert((#obj0.outputs+#obj0.inputs)<Design.Container.MAX_CONNECTIONS, obj0.name .. " has too many connections")
      assert(#obj1.inputs<Design.Transfer.MAX_INPUTS, obj1.name .. " has too many outputs")
      assert(not hasvalue(obj0.outputs, obj1), obj0.name .. " is already connected to " .. obj1.name)
      -- Perform connections.
      obj0.outputs[#obj0.outputs+1] = obj1
      obj1.inputs[#obj1.inputs+1] = obj0
    -- Transfer connected to Container.
    elseif isinstance(obj0, Design.Transfer.new()) and isinstance(obj1, Design.Container.new()) then
      -- Verify connections.
      assert(obj0.output==false, obj0.name .. " has an output set")
      assert((#obj1.inputs+#obj1.outputs)<Design.Container.MAX_CONNECTIONS, obj1.name .. " has too many connections")
      assert(obj0.output~=obj1, obj0.name .. " is already connected to " .. obj1.name)
      -- Perform connections.
      obj0.output = obj1
      obj1.inputs[#obj1.inputs+1] = obj0
      -- Update Container.
      Design.Container.add_ingredient(obj1, obj0.ingredient)
    else
      assert(false, "connection failed")
    end
    -- Update design.
    if not hasvalue(design.nodes, obj0) then
      design.nodes[#design.nodes+1] = obj0
    end 
    if not hasvalue(design.nodes, obj1) then
      design.nodes[#design.nodes+1] = obj1
    end 
  end,
  
  check = function(design)
    assert(isinstance(design, Design.new()))  
    for _, node in pairs(design.nodes) do
      -- Perform Industry-specific operations.
      if isinstance(node, Design.Industry.new()) then
        -- Check and make sure the Industry is getting all of its ingredients.
        for _, ingredient_amount in pairs(node.ingredient.ingredients) do
          local ingredient = ingredient_amount[1]
          local found = false
          for _, container in pairs(node.inputs) do
            for _, ingredient0 in pairs(container.ingredients) do
              if ingredient==ingredient0 then
                found = true
              end
            end
          end
          assert(found==true, "production that produces " .. node.ingredient.name .. " is missing ingredient " .. ingredient.name)
        end
        assert(#node.ingredient.ingredients>0, "production that produces " .. node.ingredient.name .. " is missing ingredients")
        -- Check and make sure the same container isn't used as both an input and an output.
        for _, input in pairs(node.inputs) do
          assert(input~=node.output, "production that produces " .. node.ingredient.name .. " has an input the same as its output")
        end
      -- Perform Transfer-specific operations.
      elseif isinstance(node, Design.Transfer.new()) then
        local found = false
        for _, input in pairs(node.inputs) do
          if hasvalue(input.ingredients, node.ingredient) then
            found = true
            break
          end
        end
        assert(found, "inputs of node " .. node.name .. " don't have " .. node.ingredient.name)
      end
    end
  end,
  
  print_ingredients_in_containers = function(design)
    assert(isinstance(design, Design.new()))
    for _, node in pairs(design.nodes) do
      if isinstance(node, Design.Container.new()) then
        Design.Container.print_ingredients(node)
      end
    end
  end,
  
  print_containers = function(design)
    assert(isinstance(design, Design.new()))
    for _, node in pairs(design.nodes) do
      if isinstance(node, Design.Container.new()) then
        Design.Container.print(node)
      end
    end
  end,
  
  print_statistics = function(design)
    assert(isinstance(design, Design.new()))
    
    -- Count Containers, Industries, and Transfers.
    local total_containers = 0
    local total_industries = 0
    local total_transfers = 0
    local industries = {}
    for _, node in pairs(design.nodes) do
      if isinstance(node, Design.Container.new()) then
        total_containers = total_containers+1
      elseif isinstance(node, Design.Industry.new()) then
        local industry = node.production
        if industries[industry]==nil then
          industries[industry] = 1
        else
          industries[industry] = 1+industries[industry]
        end
        total_industries = total_industries+1
      elseif isinstance(node, Design.Transfer.new()) then
        total_transfers = total_transfers+1
      end
    end
    
    -- Print out the information.
    print("container total: " .. total_containers)
    print("industry total: " .. total_industries)
    print("transfer total: " .. total_transfers)
    for industry, total in pairs(industries) do
      print(industry.name .. " total: " .. total)
    end
  end
}

function isinstance(obj0, obj1)
  assert(type(obj0)=="table", "obj0 must be a table")
  assert(type(obj1)=="table", "obj1 must be a table")
  for member1, _ in pairs(obj1) do
    local found = false
    for member0, _ in pairs(obj0) do
      if member0==member1 then
        found = true
      end 
    end
    if found == false then
      return false
    end
  end
  return true
end

function hasvalue(table, value)
  assert(type(table)=="table")
  for _, table_value in pairs(table) do
    if table_value==value then
      return true
    end 
  end
  return false
end

-- Craft list
bauxite = Item.new("bauxite")
coal = Item.new("coal")
hematite = Item.new("hematite")
quartz = Item.new("quartz")
pure_hydrogen = Item.new("pure_hydrogen")
pure_aluminum = Item.new("pure_aluminum")
pure_carbon = Item.new("pure_carbon")
pure_iron = Item.new("pure_iron")
pure_silicon = Item.new("pure_silicon")
silumin = Item.new("silumin")
basic_screw = Item.new("basic_screw")
basic_pipe = Item.new("basic_pipe")
basic_burner = Item.new("basic_burner")
smelter_m = Item.new("smelter_m")
refiner_m = Item.new("refiner_m")
basic_power_system = Item.new("basic_power_system")
al_fe_alloy = Item.new("al_fe_alloy")
basic_connector = Item.new("basic_connector")
electronics_industry_m = Item.new("electronics_industry_m")
basic_electronics = Item.new("basic_electronics")
polycarbonate_plastic = Item.new("polycarbonate_plastic")
chemical_industry_m = Item.new("chemical_industry_m")
assembly_line_m = Item.new("assembly_line_m")
basic_mobile_panel_m = Item.new("basic_mobile_panel_m")
metalwork_industry_m = Item.new("metalwork_industry_m")
basic_reinforced_frame_m = Item.new("basic_reinforced_frame_m")
assembly_line_s = Item.new("assembly_line_s")
basic_mobile_panel_s = Item.new("basic_mobile_panel_s")
basic_reinforced_frame_s = Item.new("basic_reinforced_frame_s")
steel = Item.new("steel")
basic_chemical_container_m = Item.new("basic_chemical_container_m")
basic_robotic_arm_m = Item.new("basic_robotic_arm_m")
basic_component = Item.new("basic_component")
atmospheric_engine_m = Item.new("atmospheric_engine_m")
basic_injector = Item.new("basic_injector")
_3d_printer_m = Item.new("3d_printer_m")
basic_combustion_chamber_m = Item.new("basic_combustion_chamber_m")
adjustor_m = Item.new("adjustor_m")
container_s = Item.new("container_s")
basic_hydraulics = Item.new("basic_hydraulics")
container_m = Item.new("container_m")
assembly_line_l = Item.new("assembly_line_l")
basic_mobile_panel_l = Item.new("basic_mobile_panel_l")
basic_reinforced_frame_l = Item.new("basic_reinforced_frame_l")
basic_standard_frame_s = Item.new("basic_standard_frame_s")
transfer_unit = Item.new("transfer_unit")
basic_standard_frame_l = Item.new("basic_standard_frame_l")
basic_robotic_arm_l = Item.new("basic_robotic_arm_l")
pure_oxygen = Item.new("pure_oxygen")
stabilizer_m = Item.new("stabilizer_m")
stabilizer_s = Item.new("stabilizer_s")
basic_gaz_cylinder_s = Item.new("basic_gaz_cylinder_s")
container_l = Item.new("container_l")
hover_engine_m = Item.new("hover_engine_m")
atmospheric_airbrake_m = Item.new("atmospheric_airbrake_m")
atmospheric_fuel_s = Item.new("atmospheric_fuel_s")
basic_chemical_container_s = Item.new("basic_chemical_container_s")
recycle_m = Item.new("recycle_m")
screen_m = Item.new("screen_m")
uncommon_component = Item.new("uncommon_component")
calcium_reinforced_copper = Item.new("calcium_reinforced_copper")
pure_copper = Item.new("pure_copper")
malachite = Item.new("malachite")
pure_calcium = Item.new("pure_calcium")
uncommon_electronics = Item.new("uncommon_electronics")
polycalcite_plastic = Item.new("polycalcite_plastic")
uncommon_screen_xs = Item.new("uncommon_screen_xs")
basic_led = Item.new("basic_led")
glass = Item.new("glass")
uncommon_casing_xs = Item.new("uncommon_casing_xs")
assembly_line_xs = Item.new("assembly_line_xs")
uncommon_led = Item.new("uncommon_led")
advanced_glass = Item.new("advanced_glass")
pure_sodium = Item.new("pure_sodium")
glass_furnace_m = Item.new("glass_furnace_m")
basic_power_transformer_m = Item.new("basic_power_transformer")
natron = Item.new("natron")
limestone = Item.new("limestone")

basic_power_transformer_m.ingredients = {
  {steel, 49}, {basic_component, 25}}
basic_power_transformer_m.produced = 1
basic_power_transformer_m.production_list = {electronics_industry_m}

glass_furnace_m.ingredients = {
  {basic_pipe, 36}, {basic_burner, 25},
  {basic_power_transformer_m, 1}, 
  {basic_reinforced_frame_m, 1}}
glass_furnace_m.produced = 1
glass_furnace_m.production_list = {assembly_line_m}
  
pure_sodium.ingredients = {
  {natron, 65}}
pure_sodium.produced = 45
pure_sodium.production_list = {refiner_m}

advanced_glass.ingredients = {
  {pure_sodium, 100}, {pure_calcium, 50}, 
  {pure_silicon, 50}, {pure_oxygen, 50}}
advanced_glass.produced = 75
advanced_glass.production_list = {glass_furnace_m}
  
uncommon_led.ingredients = {
  {glass, 5}, {advanced_glass, 5}}
uncommon_led.produced = 10
uncommon_led.production_list = {glass_furnace_m}

assembly_line_xs.ingredients = {
  {basic_screw, 1}, {basic_power_system, 1}, 
  {basic_mobile_panel_xs, 1}, {basic_reinforced_frame_xs, 1}}
assembly_line_xs.produced = 1
assembly_line_xs.production_list = {assembly_line_xs}

uncommon_casing_xs.ingredients = {{polycalcite_plastic, 1}, {polycarbonate_plastic, 1}}
uncommon_casing_xs.produced = 1
uncommon_casing_xs.production_list = {_3d_printer_m}

glass.ingredients = {{pure_silicon, 100}, {pure_oxygen, 50}}
glass.produced = 75
glass.production_list = {glass_furnace_m}

basic_led.ingredients = {{glass, 10}}
basic_led.produced = 10
basic_led.production_list = {glass_furnace_m}

uncommon_screen_xs.ingredients = {
  {basic_led, 1}, {basic_electronics, 1}, {polycalcite_plastic, 1},
  {uncommon_led, 1}, {uncommon_electronics, 1}}
uncommon_screen_xs.produced = 1
uncommon_screen_xs.production_list = {_3d_printer_m}

polycalcite_plastic.ingredients = {
  {pure_calcium, 100}, {pure_carbon, 50}, {pure_hydrogen, 50}}
polycalcite_plastic.produced = 75
polycalcite_plastic.production_list = {chemical_industry_m}

uncommon_electronics.ingredients = {
  {polycarbonate_plastic, 2}, {basic_component, 4}, 
  {polycalcite_plastic, 4}}
uncommon_electronics.produced = 1
uncommon_electronics.production_list = {electronics_industry_m}

pure_calcium.ingredients = {{limestone, 65}}
pure_calcium.produced = 45
pure_calcium.production_list = {refiner_m}

pure_copper.ingredients = {{malachite, 65}}
pure_copper.produced = 45
pure_copper.production_list = {refiner_m}

calcium_reinforced_copper.ingredients = {
  {pure_copper, 100}, {pure_calcium, 50}}
calcium_reinforced_copper.produced = 75
calcium_reinforced_copper.production_list = {smelter_m}

uncommon_component.ingredients = {
  {al_fe_alloy, 5}, {calcium_reinforced_copper, 5}}
uncommon_component.produced = 10
uncommon_component.production_list = {electronics_industry_m}

screen_m.ingredients = {
  {basic_component, 1}, {uncommon_component, 1}, 
  {uncommon_electronics, 1}, {uncommon_screen_xs, 1}, {uncommon_casing_xs, 1}}
screen_m.produced = 1
screen_m.production_list = {assembly_line_xs}

recycle_m.ingredients = {
  {basic_pipe, 36}, {basic_burner, 25}, 
  {basic_mobile_panel_m, 1}, {basic_reinforced_frame_m, 1}}
recycle_m.produced = 1
recycle_m.production_list = {assembly_line_m}  

basic_chemical_container_s.ingredients = {
  {silumin, 7}, {basic_screw, 5}}
basic_chemical_container_s.produced = 1
basic_chemical_container_s.production_list = {metalwork_industry_m}

atmospheric_fuel_s.ingredients = {
  {basic_pipe, 6}, {basic_injector, 5},
  {basic_chemical_container_s, 1}, {basic_standard_frame_s, 1}}
atmospheric_fuel_s.produced = 1
atmospheric_fuel_s.production_list = {assembly_line_s}

atmospheric_airbrake_m.ingredients = {
  {basic_pipe, 6}, {basic_hydraulics, 5}, 
  {basic_mobile_panel_s, 1}, {basic_standard_frame_s, 1}}
atmospheric_airbrake_m.produced = 1
atmospheric_airbrake_m.production_list = {assembly_line_s}

hover_engine_m.ingredients = {
  {basic_screw, 6}, {basic_injector, 5},
  {basic_gaz_cylinder_s, 1}, {basic_reinforced_frame_s, 1}}
hover_engine_m.produced = 1
hover_engine_m.production_list = {assembly_line_s}

stabilizer_s.ingredients = {
  {basic_screw, 6}, {basic_hydraulics, 5}, 
  {basic_mobile_panel_s, 1}, {basic_reinforced_frame_s, 1}}
stabilizer_s.produced = 1
stabilizer_s.production_list = {assembly_line_s}

container_l.ingredients = {
  {basic_component, 432}, {basic_hydraulics, 250}, {basic_reinforced_frame_l, 1}}
container_l.produced = 1
container_l.production_list = {assembly_line_l}

basic_gaz_cylinder_s.ingredients = {
  {silumin, 7}, {basic_screw, 5}}
basic_gaz_cylinder_s.produced = 1
basic_gaz_cylinder_s.production_list = {metalwork_industry_m}

stabilizer_m.ingredients = {
  {basic_screw, 36}, {basic_hydraulics, 25},
  {basic_mobile_panel_m, 1}, {basic_reinforced_frame_m, 1}}
stabilizer_m.produced = 1
stabilizer_m.production_list = {assembly_line_m}

basic_robotic_arm_l.ingredients = {
  {silumin, 343}, {basic_component, 125}}
basic_robotic_arm_l.produced = 1
basic_robotic_arm_l.production_list = {metalwork_industry_m}

basic_standard_frame_l.ingredients = {
  {silumin, 515}}
basic_standard_frame_l.produced = 1
basic_standard_frame_l.production_list = {metalwork_industry_m}

transfer_unit.ingredients = {
  {basic_pipe, 216}, {basic_hydraulics, 125}, 
  {basic_robotic_arm_l, 1}, {basic_standard_frame_l, 1}}
transfer_unit.produced = 1
transfer_unit.production_list = {assembly_line_l}

basic_standard_frame_s.ingredients = {
  {silumin, 11}}
basic_standard_frame_s.produced = 1
basic_standard_frame_s.production_list = {metalwork_industry_m}

basic_reinforced_frame_l.ingredients = {
  {steel, 515}}
basic_reinforced_frame_l.produced = 1
basic_reinforced_frame_l.production_list = {metalwork_industry_m}

basic_mobile_panel_l.ingredients = {
  {silumin, 343}, {basic_screw, 125}}
basic_mobile_panel_l.produced = 1
basic_mobile_panel_l.production_list = {metalwork_industry_m}

assembly_line_l.ingredients = {
  {basic_screw, 216}, {basic_power_system, 125},
  {basic_mobile_panel_l, 1}, {basic_reinforced_frame_l, 1}}
assembly_line_l.produced = 1
assembly_line_l.production_list = {assembly_line_m, assembly_line_l}

container_m.ingredients = {
  {basic_component, 216}, {basic_hydraulics, 125}, {basic_reinforced_frame_m, 1}}
container_m.produced = 1
container_m.production_list = {assembly_line_l}

basic_hydraulics.ingredients = {
  {steel, 6}, {basic_pipe, 4}}
basic_hydraulics.produced = 1
basic_hydraulics.production_list = {metalwork_industry_m}

container_s.ingredients = {
  {basic_component, 36}, {basic_hydraulics, 25},
  {basic_reinforced_frame_m, 1}}
container_s.produced = 1
container_s.production_list = {assembly_line_m}

adjustor_m.ingredients = {
  {basic_pipe, 6}, {basic_injector, 5},
  {basic_gaz_cylinder_s, 1}, {basic_standard_frame_s, 1}}
adjustor_m.produced = 1
adjustor_m.production_list = {assembly_line_s}

basic_combustion_chamber_m.ingredients = {
  {steel, 49},
  {basic_pipe, 25}}
basic_combustion_chamber_m.produced = 1
basic_combustion_chamber_m.production_list = {metalwork_industry_m}

_3d_printer_m.ingredients = {
  {basic_pipe, 36},
  {basic_injector, 25},
  {basic_robotic_arm_m, 1},
  {basic_reinforced_frame_m, 1}}
_3d_printer_m.produced = 1
_3d_printer_m.production_list = {assembly_line_m}

basic_injector.ingredients = {
  {polycarbonate_plastic, 6},
  {basic_screw, 4}}
basic_injector.produced = 4
basic_injector.production_list = {_3d_printer_m}

atmospheric_engine_m.ingredients = {
  {basic_screw, 36},
  {basic_injector, 25},
  {basic_combustion_chamber_m, 1},
  {basic_reinforced_frame_m, 1}}
atmospheric_engine_m.produced = 1
atmospheric_engine_m.production_list = {assembly_line_m}

basic_component.ingredients = {{al_fe_alloy, 10}}
basic_component.produced = 10
basic_component.production_list = {electronics_industry_m}

basic_robotic_arm_m.ingredients = {{silumin, 49}, {basic_component, 25}}
basic_robotic_arm_m.produced = 1
basic_robotic_arm_m.production_list = {metalwork_industry_m}

basic_chemical_container_m.ingredients = {{silumin, 49}, {basic_screw, 25}}
basic_chemical_container_m.produced = 1
basic_chemical_container_m.production_list = {metalwork_industry_m}

steel.ingredients = {{pure_iron, 100}, {pure_carbon, 50}}
steel.produced = 75
steel.production_list = {smelter_m}

basic_reinforced_frame_s.ingredients = {{steel, 11}}
basic_reinforced_frame_s.produced = 1
basic_reinforced_frame_s.production_list = {metalwork_industry_m}

basic_mobile_panel_s.ingredients = {
  {silumin, 7},
  {basic_screw, 5}}
basic_mobile_panel_s.produced = 1
basic_mobile_panel_s.production_list = {metalwork_industry_m}

assembly_line_s.ingredients = {
  {basic_screw, 6},
  {basic_power_system, 5},
  {basic_mobile_panel_s, 1},
  {basic_reinforced_frame_s, 1}}
assembly_line_s.produced = 1
assembly_line_s.production_list = {assembly_line_s}

basic_reinforced_frame_m.ingredients = {{steel, 74}}
basic_reinforced_frame_m.produced = 1
basic_reinforced_frame_m.production_list = {metalwork_industry_m}
  
metalwork_industry_m.ingredients = {
  {basic_pipe, 36},
  {basic_power_system, 25},
  {basic_mobile_panel_m, 1},
  {basic_reinforced_frame_m, 1}}
metalwork_industry_m.produced = 1
metalwork_industry_m.production_list = {assembly_line_m}

basic_mobile_panel_m.ingredients = {
  {silumin, 49},
  {basic_screw, 25}}
basic_mobile_panel_m.produced = 1
basic_mobile_panel_m.production_list = {metalwork_industry_m}

assembly_line_m.ingredients = {
  {basic_screw, 36},
  {basic_power_system, 25},
  {basic_mobile_panel_m, 1},
  {basic_reinforced_frame_m, 1}}
assembly_line_m.produced = 1
assembly_line_m.production_list = {assembly_line_m, assembly_line_s}

chemical_industry_m.ingredients = {
    {basic_pipe, 36},
    {basic_power_system, 25}}
chemical_industry_m.produced = 1
chemical_industry_m.production_list = {assembly_line_m}

polycarbonate_plastic.ingredients = {
    {pure_carbon, 100},
    {pure_hydrogen, 50}}
polycarbonate_plastic.produced = 75
polycarbonate_plastic.production_list = {chemical_industry_m}

basic_electronics.ingredients = {
    {polycarbonate_plastic, 6},
    {basic_component, 4}}
basic_electronics.produced = 1
basic_electronics.production_list = {electronics_industry_m}

electronics_industry_m.ingredients = {
    {basic_pipe, 36},
    {basic_electronics, 25},
    {basic_robotic_arm_m, 1},
    {basic_reinforced_frame_m, 1}}
electronics_industry_m.produced = 1
electronics_industry_m.production_list = {assembly_line_m}

basic_connector.ingredients = {{al_fe_alloy, 10}}
basic_connector.produced = 10
basic_connector.production_list = {electronics_industry_m}

al_fe_alloy.ingredients = {
    {pure_aluminum, 100},
    {pure_iron, 50}}
al_fe_alloy.produced = 75
al_fe_alloy.production_list = {smelter_m}

basic_power_system.ingredients = {
    {al_fe_alloy, 6},
    {basic_connector, 4}}
basic_power_system.produced = 1
basic_power_system.production_list = {electronics_industry_m}

refiner_m.ingredients = {
    {basic_pipe, 36},
    {basic_power_system, 25},
    {basic_chemical_container_m, 1},
    {basic_reinforced_frame_m, 1}}
refiner_m.produced = 1
refiner_m.production_list = {assembly_line_m}

pure_aluminum.ingredients = {{bauxite, 65}}
pure_aluminum.produced = 45
pure_aluminum.production_list = {refiner_m}

pure_carbon.ingredients = {{coal, 65}}
pure_carbon.produced = 45
pure_carbon.production_list = {refiner_m}

pure_iron.ingredients = {{hematite, 65}}
pure_iron.produced = 45
pure_iron.production_list = {refiner_m}

pure_silicon.ingredients = {{quartz, 65}}
pure_silicon.produced = 45
pure_silicon.production_list = {refiner_m}

basic_screw.ingredients = {{steel, 10}}
basic_screw.produced = 10
basic_screw.production_list = {metalwork_industry_m}

basic_burner.ingredients = {{silumin, 6}, {basic_screw, 4}}
basic_burner.produced = 1
basic_burner.production_list = {metalwork_industry_m}

silumin.ingredients = {{pure_aluminum, 100}, {pure_silicon, 50}}
silumin.produced = 75
silumin.production_list = {smelter_m}

basic_pipe.ingredients = {{silumin, 10}}
basic_pipe.produced = 10
basic_pipe.production_list = {metalwork_industry_m}

smelter_m.ingredients = {
    {basic_pipe, 36},
    {basic_burner, 25},
    {basic_chemical_container_m, 1},
    {basic_reinforced_frame_m, 1}}
smelter_m.produced = 1
smelter_m.production_list = {assembly_line_m}