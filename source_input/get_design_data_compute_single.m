function [eval_ann, data_compute] = get_design_data_compute_single(eval_type)
% Return the data required for the computation of a single inductor design.
%
%    How to evaluate the ANN/regression.
%    Data required for the inductor evaluation.
%
%    Parameters:
%        eval_type (str): type of the evaluation ('fem', 'ann', or approx')
%
%    Returns:
%        eval_ann (struct): data for controlling the evaluation of the ANN/regression
%        data_compute (struct): data for the inductor designs
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% data for controlling the evaluation of the ANN/regression:
%    - geom_type: type of the geometry input variables
%        - 'rel': boxed volume, geometrical aspect ratio, and relative air gap length
%        - 'abs': absolute core, winding, and air gap length
%    - eval_type: type of the ANN/regression evaluation
%        - 'ann': get the result of the ANN/regression
%        - 'fem': get the FEM solution without the ANN/regression
%        - 'approx': get the analytical solution without the ANN/regression
eval_ann.geom_type = 'abs';
eval_ann.eval_type = eval_type;

% inductor data (data which are not only numeric)
data_compute.data_const = get_design_data_const();

% inductor data (struct of scalars)
data_compute.data_vec = get_data_vec();

% function for getting the operating points data (struct containing the operating points)
data_compute.fct_excitation = @(fom) get_excitation(fom);

end

function data_vec = get_data_vec()
% Function for getting the inductor data (struct of scalars).
%
%    Returns:
%        data_vec (struct:) struct of scalars

% inductor geometry
%    - x_window: width of the winding window
%    - y_window: height of the winding window
%    - t_core: width of the central core limb
%    - z_core: depth of the core
%    - d_gap: air gap length (physical air gap)
%    - n_turn: inductor number of turns
%    - fill_pack: fill factor of the packing (not of the litz wire)
geom.x_window = 10.15e-3;
geom.y_window = 37.40e-3;
geom.t_core = 17.00e-3;
geom.z_core = 20.80e-3;
geom.d_gap = 0.40e-3;
geom.n_turn = 16;
geom.fill_pack = 0.7;

% inductor material
%    - winding_id: id of the winding material
%    - core_id: id of the core material
%    - iso_id: id of the insulation material
material.winding_id = get_map_str_to_int('100um');
material.core_id = get_map_str_to_int('N87_meas');
material.iso_id = get_map_str_to_int('default');

% minimum frequency
f = 300e3;

% get the all the data
data_vec = get_design_data_vec(geom, material, f);

end

function excitation = get_excitation(fom)
% Function for getting the operating points data (struct of struct of scalars).
%
%    Parameters:
%        fom (struct): computed inductor figures of merit
%
%    Returns:
%        excitation (struct): struct containing the operating points (e.g., full load, partial load)

% extract inductance
L = fom.circuit.L;

% frequency vector
f_vec = [300e3, 400e3, 500e3, 600e3];

% load conditions
load_full_load = 1.0;
load_partial_load = 0.5;

% assign excitation
for i=1:length(f_vec)
    tag = sprintf('full_load_f_%.0fk', 1e-3.*f_vec(i));
    excitation_tmp = get_design_excitation(L, f_vec(i), load_full_load);
    excitation.(tag) = excitation_tmp;
    
    tag = sprintf('partial_load_f_%.0fk', 1e-3.*f_vec(i));
    excitation_tmp = get_design_excitation(L, f_vec(i), load_partial_load);
    excitation.(tag) = excitation_tmp;
end

end
