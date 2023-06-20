def find_perfect_power(a, b)
  while a % b == 0
    a = a / b
  end

  if a == 1
    return b
  end

  false
end

def modinv(a, m)
  return m if m == 1
  m0, inv, x0 = m, 1, 0
  while a > 1
    inv -= (a / m) * x0
    a, m = m, a % m
    inv, x0 = x0, inv
  end
  inv += m0 if inv < 0
  inv
end

def sieve_of_erathostenes(n)
  primes = (0..n).to_a
  primes[0] = primes[1] = nil

  primes.each do |p|
    next unless p

    break if p * p > n

    (p * p).step(n, p) { |m| primes[m] = nil }
  end

  primes.compact
end

def lenstra(n)
  # check if isnt disivble by 2 or 3
  if n % 2 == 0
    return lenstra(n / 2)
  end

  if n % 3 == 0
    return lenstra(n / 3)
  end

  # check if isnt perfect power
  (2..Math.log2(n)).each do |k|
    perfect_power = find_perfect_power(n, k)
    if perfect_power != false
      return lenstra(n / perfect_power)
    end
  end

  # try not more than this many times
  limit = 1000
  limit.times do

    d = n
    a, x1, y1 = nil
    while d == n
      a = rand(1..n)
      x1 = rand(1..n)
      y1 = rand(1..n)

      b = (y1 ** 2 - x1 ** 3 - a * x1) % n

      d = (4 * a ** 3 + 27 * b ** 2).gcd(n)
    end

    # now we have point P = (x1, y1) on an elliptic curve y^2 = x^3 + ax + b

    # sometimes we'll find a lucky factor
    if d > 1 && d < n
      return d
    end

    # k is how many times we're gonna add point P to itself, so we'll have kP
    # we can try different values of k such as:
    # k = lcm(2, 3, . . . , B) for some integer B ≈ 100 == sieve_of_erathostenes(B).reduce(1, :lcm)
    # k = 10! == 3628800
    k = 3628800

    # bigger values of k lead to a bigger chance of finding a factor of n, but slow down the computation

    # if points have the same coordinates
    # s = (3x^2 + a)/(2y)
    s1 = 3 * x1 ** 2 + a
    s2 = 2 * y1

    # if gcd(s2, n) != 1, then that means we can't invert s2 mod n, so gcd(s2, n) is a factor of n
    if s2.gcd(n) != 1
      return s2.gcd(n)
    end

    kp = []

    # doubling p => kp = 2p
    s = (s1 * modinv(s2, n)) % n

    x3 = (s ** 2 - 2 * x1) % n
    y3 = (s * (x1 - x3) - y1) % n
    kp[0] = x3
    kp[1] = y3

    # Now we are trying consecutive points 3P, 4P... until we find a point for which gcd(s2, n) != 1

    # adding kp + p
    k.times do
      # if points have different coordinates
      # s = (x2-x1)/(y2-y1)
      s1 = kp[1] - y1
      s2 = kp[0] - x1

      if s2.gcd(n) != 1
        return s2.gcd(n)
      end

      s = (s1 * modinv(s2, n)) % n
      x3 = (s ** 2 - 2 * x1) % n
      y3 = (s * (x1 - x3) - y1) % n
      kp[0] = x3
      kp[1] = y3
    end
  end

  # if after 'limit' number of times we haven't found a factor, return nil; we can try different values for 'limit'
  nil
end

n = gets.to_i
factor = lenstra(n)

if factor != nil
  puts factor
  puts n / factor
else
  puts "No factors found."
end