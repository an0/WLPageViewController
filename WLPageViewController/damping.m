## k = 80
## m = 125
## c = 200

t = 0:0.1:10;

## w_0 = sqrt(k / m)
## zeta = c / (2 * sqrt(m * k))
## zeta_w_0 = c / (2 * m)
w_0 = .7
zeta = 1

if abs(zeta - 1) < 0.001
# critical damping
  printf('Critical damping\n');
  A = x_0
  B = v_0 + w_0 * x_0
  x = (A + B * t) .* power(e, -w_0 * t);
  t_max = 1 / w_0 - A / B
  x_max = (v_0 + w_0 * x_0) / w_0 * e^(-v_0 / (v_0 + w_0 * x_0))
elseif zeta < 1
  # under-damping
  printf('Under-damping\n');
  w_d = w_0 * sqrt(1 - zeta * zeta)
  A = x_0
  B = (zeta * x_0 + v_0) / w_d
  x = power(e, -zeta * w_0 * t) .* (A * cos(w_d * t) + B * sin(w_d * t));
  a = B * w_d - A * zeta * w_0
  b = A * w_d + B * zeta * w_0
  sin_max = sqrt(a^2 / (a^2 + b^2))
  if a * b > 0
    theta_max = asin(sin_max)
    theta_max = [theta_max, theta_max + pi, theta_max + 2 * pi]
  else
    theta_max = pi - asin(sin_max)
    theta_max = [theta_max, theta_max + pi]
  end
    t_max = theta_max / w_d
    x_max = power(e, -zeta * w_0 * t_max) .* (A * cos(w_d * t_max) + B * sin(w_d * t_max))
else
  # over-damping
  printf('Over-damping\n');
  g_b = 2 * zeta * w_0;
  g_c = w_0 * w_0;
  g_delta = sqrt(g_b * g_b - 4 * g_a * g_c);
  gamma_1 = (-g_b + g_delta) / 2;
  gamma_2 = (-g_b - g_delta) / 2;
  A = x_0 + (gamma_1 * x_0 - v_0) / (gamma_2 - gamma_1);
  B = -(gamma_1 * x_0 - v_0) / (gamma_2 - gamma_1);
  x = A * power(e, gamma_1 * t) + B * power(e, gamma_2 * t);
end

plot(t, x)
