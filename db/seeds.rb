require 'open-uri'

puts "Eliminando productos existentes..."
Product.destroy_all

puts "Creando productos de prueba..."

image_urls = [
  "https://unsplash.com/es/fotos/un-vaso-de-agua-encima-de-un-monton-de-hojas-jFA3RNJ8Mi0",
  "https://images.unsplash.com/photo-1632883199436-b4148e338609?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bWV6Y2FsfGVufDB8fDB8fHww",
  "https://images.unsplash.com/photo-1642997607473-6052794d8cb2?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
]

10.times do |i|
  product = Product.create!(
    name: "Mezcal de prueba #{i + 1}",
    slug: "mezcal-prueba-#{i + 1}",
    category: Product::CATEGORIES.sample,
    price: rand(250..850),
    description: "Este es un mezcal artesanal de prueba número #{i + 1}. Perfecto para quienes buscan un sabor auténtico.",
    short_description: "Mezcal suave, ahumado y tradicional.",
    abv: rand(40.0..50.0).round(1),
    volume: [375, 500, 750].sample,
    origin: "Oaxaca, México",
    ingredients: ["Agave espadín", "Agua", "Tiempo"],
    featured: [true, false].sample,
    new: [true, false].sample,
    rating: rand(3.5..5.0).round(1)
  )

  image_url = image_urls[i % image_urls.length]
  file = URI.open(image_url)
  product.images.attach(io: file, filename: "mezcal#{i + 1}.jpg", content_type: "image/jpeg")

  puts "✅ Producto #{product.name} creado con imagen"
end

puts "✅ Seeding completado."
