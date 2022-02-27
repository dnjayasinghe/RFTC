
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name sasebo_giii_aes -dir "D:/Downloads/sasebo_giii_materials (2)/sasebo_giii/sasebo_giii_aes/sasebo_giii_aes/planAhead_run_1" -part xc7k325tfbg676-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Downloads/sasebo_giii_materials (2)/sasebo_giii/sasebo_giii_aes/sasebo_giii_aes/CHIP_SASEBO_GIII_AES.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Downloads/sasebo_giii_materials (2)/sasebo_giii/sasebo_giii_aes/sasebo_giii_aes} }
set_property target_constrs_file "D:/Downloads/sasebo_giii_materials (2)/sasebo_giii/sasebo_giii_aes/pin_sasebo_giii_k7.ucf" [current_fileset -constrset]
add_files [list {D:/Downloads/sasebo_giii_materials (2)/sasebo_giii/sasebo_giii_aes/pin_sasebo_giii_k7.ucf}] -fileset [get_property constrset [current_run]]
link_design
