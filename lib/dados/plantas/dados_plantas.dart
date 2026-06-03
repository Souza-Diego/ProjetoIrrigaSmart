import 'package:flutter/material.dart';

class DadosPlanta {
  final String emoji;
  final String nome;
  final String descricao;
  final String umidadeIdeal;
  final String frequencia;
  final String duracaoSugerida;
  final String volumePorRega;
  final String exposicaoSolar;
  final String ambienteIdeal;
  final String sensibilidadeExcesso;
  final int umidadeMinimaValor;
  final int duracaoSegundos;
  final Color cor;

  const DadosPlanta({
    required this.emoji,
    required this.nome,
    required this.descricao,
    required this.umidadeIdeal,
    required this.frequencia,
    required this.duracaoSugerida,
    required this.volumePorRega,
    required this.exposicaoSolar,
    required this.ambienteIdeal,
    required this.sensibilidadeExcesso,
    required this.umidadeMinimaValor,
    required this.duracaoSegundos,
    required this.cor,
  });
}

const List<DadosPlanta> listaPlantas = [
  DadosPlanta(
    emoji: '🌿',
    nome: 'Samambaia',
    descricao:
        'Planta ornamental que prefere ambientes úmidos e sombreados. Sensível ao ressecamento do substrato.',
    umidadeIdeal: '60–70%',
    frequencia: '2× ao dia',
    duracaoSugerida: '2 min 15s',
    volumePorRega: '~900 ml',
    exposicaoSolar: 'Sombra / meia-sombra',
    ambienteIdeal: 'Interno',
    sensibilidadeExcesso: 'Média',
    umidadeMinimaValor: 60,
    duracaoSegundos: 135,
    cor: Color(0xFF1D9E75),
  ),
  DadosPlanta(
    emoji: '🌵',
    nome: 'Cacto',
    descricao:
        'Planta resistente à seca. O substrato deve secar completamente entre regas.',
    umidadeIdeal: '20–30%',
    frequencia: '1× por semana',
    duracaoSugerida: '30s',
    volumePorRega: '~200 ml',
    exposicaoSolar: 'Pleno sol (6h+)',
    ambienteIdeal: 'Externo',
    sensibilidadeExcesso: 'Alta',
    umidadeMinimaValor: 20,
    duracaoSegundos: 30,
    cor: Color(0xFF639922),
  ),
  DadosPlanta(
    emoji: '🍅',
    nome: 'Tomate',
    descricao:
        'Hortaliça exigente em água, especialmente no florescimento. Solo deve permanecer úmido de forma uniforme.',
    umidadeIdeal: '55–65%',
    frequencia: '2× ao dia',
    duracaoSugerida: '3 min',
    volumePorRega: '~1,2 L',
    exposicaoSolar: 'Pleno sol (6–8h)',
    ambienteIdeal: 'Externo',
    sensibilidadeExcesso: 'Baixa',
    umidadeMinimaValor: 55,
    duracaoSegundos: 180,
    cor: Color(0xFFD85A30),
  ),
  DadosPlanta(
    emoji: '🌿',
    nome: 'Manjericão',
    descricao:
        'Erva aromática sensível ao ressecamento. Evitar encharcar as raízes.',
    umidadeIdeal: '50–60%',
    frequencia: '1–2× ao dia',
    duracaoSugerida: '1 min 15s',
    volumePorRega: '~500 ml',
    exposicaoSolar: 'Sol direto (4–6h)',
    ambienteIdeal: 'Interno / Externo',
    sensibilidadeExcesso: 'Média',
    umidadeMinimaValor: 50,
    duracaoSegundos: 75,
    cor: Color(0xFF1D9E75),
  ),
  DadosPlanta(
    emoji: '🥬',
    nome: 'Alface',
    descricao:
        'Hortaliça folhosa que prefere solo úmido e fresco. Sensível ao calor excessivo.',
    umidadeIdeal: '55–65%',
    frequencia: '2× ao dia',
    duracaoSugerida: '1 min 45s',
    volumePorRega: '~700 ml',
    exposicaoSolar: 'Meia-sombra (2–4h)',
    ambienteIdeal: 'Interno / Externo',
    sensibilidadeExcesso: 'Baixa',
    umidadeMinimaValor: 55,
    duracaoSegundos: 105,
    cor: Color(0xFF639922),
  ),
  DadosPlanta(
    emoji: '🌹',
    nome: 'Rosa',
    descricao:
        'Flor que exige rega moderada e regular. Evitar molhar pétalas e folhas.',
    umidadeIdeal: '40–50%',
    frequencia: '1× ao dia',
    duracaoSugerida: '1 min 45s',
    volumePorRega: '~700 ml',
    exposicaoSolar: 'Pleno sol (6h+)',
    ambienteIdeal: 'Externo',
    sensibilidadeExcesso: 'Média',
    umidadeMinimaValor: 40,
    duracaoSegundos: 105,
    cor: Color(0xFFD4537E),
  ),
  DadosPlanta(
    emoji: '🌱',
    nome: 'Lavanda',
    descricao:
        'Planta aromática mediterrânea. Prefere solo bem drenado e seco entre as regas.',
    umidadeIdeal: '30–40%',
    frequencia: '2× por semana',
    duracaoSugerida: '45s',
    volumePorRega: '~300 ml',
    exposicaoSolar: 'Pleno sol (6–8h)',
    ambienteIdeal: 'Externo',
    sensibilidadeExcesso: 'Alta',
    umidadeMinimaValor: 30,
    duracaoSegundos: 45,
    cor: Color(0xFF7F77DD),
  ),
  DadosPlanta(
    emoji: '🍓',
    nome: 'Morango',
    descricao:
        'Fruta que necessita de umidade constante nas raízes, sem encharcar o substrato.',
    umidadeIdeal: '55–65%',
    frequencia: '2× ao dia',
    duracaoSugerida: '1 min 45s',
    volumePorRega: '~700 ml',
    exposicaoSolar: 'Sol direto (6–8h)',
    ambienteIdeal: 'Externo',
    sensibilidadeExcesso: 'Média',
    umidadeMinimaValor: 55,
    duracaoSegundos: 105,
    cor: Color(0xFFD85A30),
  ),
  DadosPlanta(
    emoji: '🌻',
    nome: 'Girassol',
    descricao:
        'Planta de pleno sol. Rega moderada — tolera períodos mais secos quando adulta.',
    umidadeIdeal: '35–45%',
    frequencia: '1× ao dia',
    duracaoSugerida: '2 min',
    volumePorRega: '~800 ml',
    exposicaoSolar: 'Pleno sol (6h+)',
    ambienteIdeal: 'Externo',
    sensibilidadeExcesso: 'Baixa',
    umidadeMinimaValor: 35,
    duracaoSegundos: 120,
    cor: Color(0xFFBA7517),
  ),
  DadosPlanta(
    emoji: '🪴',
    nome: 'Suculenta',
    descricao:
        'Armazena água nas folhas. Solo deve secar completamente entre regas.',
    umidadeIdeal: '15–25%',
    frequencia: '1× por semana',
    duracaoSugerida: '15s',
    volumePorRega: '~100 ml',
    exposicaoSolar: 'Sol direto (4–6h)',
    ambienteIdeal: 'Interno / Externo',
    sensibilidadeExcesso: 'Alta',
    umidadeMinimaValor: 15,
    duracaoSegundos: 15,
    cor: Color(0xFF0F6E56),
  ),
];
