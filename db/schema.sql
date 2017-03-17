CREATE TABLE "products" (
  `name` TEXT NOT NULL,
  `price` NUMERIC NOT NULL,
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  `walmart_id` INTEGER NOT NULL UNIQUE
);

CREATE INDEX products_index ON `products` (`walmart_id`);

CREATE TABLE `reviews` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  `product_id` INTEGER NOT NULL,
  `stars` INTEGER NOT NULL,
  `title` TEXT NOT NULL,
  `author` TEXT,
  `verified` INTEGER NOT NULL DEFAULT 0,
  `published_at` TEXT NOT NULL,
  `helpful_count` INTEGER NOT NULL DEFAULT 0,
  `unhepful_count` INTEGER NOT NULL DEFAULT 0,
  `text` TEXT NOT NULL
);

CREATE VIRTUAL TABLE reviews_texts USING fts5(text, content=reviews, content_rowid=id, tokenize = 'porter unicode61');
