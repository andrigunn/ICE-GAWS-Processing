function rho_atm = AtmosphericDensity(pres,T, c)

rho_atm = 100*pres./c.R_d./T ;               % atmospheric density

end