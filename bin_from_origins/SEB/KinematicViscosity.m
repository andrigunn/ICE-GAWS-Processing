function nu = KinematicViscosity(T,rho_atm)

mu = 18.27e-6.*(291.15+120)./(T+120).*(T./291.15).^1.5;  % dynamic viscosity of air (Pa s) (Sutherlands' formula using C = 120 K)
nu = mu./rho_atm; % kinematic viscosity of air (m^2/s)

end
