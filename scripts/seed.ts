import { Pool } from 'pg';
import * as bcrypt from 'bcrypt';

const configs = {
  auth: {
    connectionString:
      process.env.AUTH_DATABASE_URL ??
      'postgresql://postgres:postgres@localhost:5435/auth_db',
  },
  admin: {
    connectionString:
      process.env.ADMIN_DATABASE_URL ??
      'postgresql://postgres:postgres@localhost:5436/admin_db',
  },
  feirante: {
    connectionString:
      process.env.FEIRANTE_DATABASE_URL ??
      'postgresql://postgres:postgres@localhost:5437/feirante_db',
  },
};

async function seedAuth() {
  const pool = new Pool(configs.auth);
  const client = await pool.connect();

  try {
    console.log('\n🟢 Seeding auth_db...');

    const adminHash = await bcrypt.hash('admin123', 10);
    const feiranteHash = await bcrypt.hash('feirante123', 10);

    await client.query(`
      INSERT INTO usuarios (nome, email, senha_hash, role)
      VALUES
        ('Administrador', 'admin@feira.com', $1, 'admin'),
        ('João Silva',    'joao@feira.com',  $2, 'feirante'),
        ('Maria Santos',  'maria@feira.com', $2, 'feirante')
      ON CONFLICT (email) DO NOTHING;
    `, [adminHash, feiranteHash]);

    console.log('   ✓ Usuários criados');
    console.log('     admin@feira.com   / admin123    (role: admin)');
    console.log('     joao@feira.com    / feirante123 (role: feirante)');
    console.log('     maria@feira.com   / feirante123 (role: feirante)');
  } finally {
    client.release();
    await pool.end();
  }
}

async function seedAdmin() {
  const pool = new Pool(configs.admin);
  const client = await pool.connect();

  try {
    console.log('\n🟣 Seeding admin_db...');

    const joaoId = '00000000-0000-0000-0000-000000000001';
    const mariaId = '00000000-0000-0000-0000-000000000002';

    await client.query(`
      INSERT INTO feirantes (id, nome, email, telefone)
      VALUES
        ($1, 'João Silva',   'joao@feira.com',  '(11) 99999-0001'),
        ($2, 'Maria Santos', 'maria@feira.com', '(11) 99999-0002')
      ON CONFLICT (email) DO NOTHING;
    `, [joaoId, mariaId]);

    await client.query(`
      INSERT INTO barracas (nome, localizacao, feirante_id)
      VALUES
        ('Barraca do João',  'Setor A - Box 01', $1),
        ('Barraca da Maria', 'Setor B - Box 05', $2)
      ON CONFLICT DO NOTHING;
    `, [joaoId, mariaId]);

    console.log('   ✓ Feirantes criados: João Silva, Maria Santos');
    console.log('   ✓ Barracas criadas: Setor A-01, Setor B-05');
  } finally {
    client.release();
    await pool.end();
  }
}

async function seedFeirante() {
  const pool = new Pool(configs.feirante);
  const client = await pool.connect();

  try {
    console.log('\n🟡 Seeding feirante_db...');

    const joaoId = '00000000-0000-0000-0000-000000000001';
    const mariaId = '00000000-0000-0000-0000-000000000002';

    // Produtos do João
    const produtosJoao = await client.query(`
      INSERT INTO produtos (feirante_id, nome, descricao, preco_unitario)
      VALUES
        ($1, 'Banana Prata',  'Banana prata madura, dúzia',    '8.00'),
        ($1, 'Mamão Formosa', 'Mamão formosa médio, unidade',  '12.00'),
        ($1, 'Abacaxi',       'Abacaxi pérola doce, unidade',  '6.50')
      RETURNING id, nome;
    `, [joaoId]);

    // Produtos da Maria
    const produtosMaria = await client.query(`
      INSERT INTO produtos (feirante_id, nome, descricao, preco_unitario)
      VALUES
        ($1, 'Tomate',       'Tomate italiano, kg',            '7.00'),
        ($1, 'Alface',       'Alface crespa, unidade',         '3.50'),
        ($1, 'Cebola',       'Cebola roxa, kg',                '9.00')
      RETURNING id, nome;
    `, [mariaId]);

    const todosProdutos = [...produtosJoao.rows, ...produtosMaria.rows];

    // Estoque inicial para cada produto
    for (const produto of todosProdutos) {
      await client.query(`
        INSERT INTO estoque_items (produto_id, quantidade)
        VALUES ($1, 50)
        ON CONFLICT DO NOTHING;
      `, [produto.id]);
    }

    console.log('   ✓ Produtos do João: Banana Prata, Mamão Formosa, Abacaxi');
    console.log('   ✓ Produtos da Maria: Tomate, Alface, Cebola');
    console.log('   ✓ Estoque inicial: 50 unidades por produto');
  } finally {
    client.release();
    await pool.end();
  }
}

async function main() {
  console.log('🌱 Iniciando seed do FeiraControl...');

  try {
    await seedAuth();
    await seedAdmin();
    await seedFeirante();

    console.log('\n✅ Seed concluído com sucesso!\n');
    console.log('Credenciais para teste:');
    console.log('  Admin:    admin@feira.com    / admin123');
    console.log('  Feirante: joao@feira.com     / feirante123');
    console.log('  Feirante: maria@feira.com    / feirante123\n');
  } catch (err) {
    console.error('\n❌ Erro durante o seed:', err);
    process.exit(1);
  }
}

main();
