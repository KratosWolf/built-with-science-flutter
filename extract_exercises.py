#!/usr/bin/env python3
"""
Script para extrair dados dos arquivos Excel do Built With Science
e gerar código Dart para mock_data.dart
"""

import pandas as pd
from datetime import datetime
from pathlib import Path

# Configurações
DATA_DIR = Path("data")
FILE_4DAY = DATA_DIR / "Intermediate (V1-4 day) Workout Tracker (1).xlsx"
FILE_5DAY = DATA_DIR / "Intermediate (V1-5 day) Program Workout Tracker (1).xlsx"

# IDs iniciais (continuando do mock_data.dart existente)
EXERCISE_ID_START = 52
VARIATION_ID_START = 103

# Mapear Program para programId
PROGRAM_MAP = {
    "4-day": 2,
    "5-day": 3
}

# Mapear Days para dayIndex (baseado nos ProgramDays já definidos)
DAY_MAP_4DAY = {
    "Upper 1": 1,
    "Lower 1 (Quad Focus)": 2,
    "Upper 2": 3,
    "Lower 2 (Glute Focus)": 4,
}

DAY_MAP_5DAY = {
    "Upper": 1,
    "Lower 1 (Quad Focus)": 2,
    "Push": 3,
    "Pull": 4,
    "Lower 2 (Glute Focus)": 5,
}


def parse_reps_target(value):
    """
    Converte o valor de RepsTarget para string adequada.
    - datetime → "{month}-{day}" (ex: datetime(2025,8,10) → "8-10")
    - string → usar direto
    - float/int → converter para string
    """
    if pd.isna(value):
        return "8-10"  # default

    if isinstance(value, datetime):
        return f"{value.month}-{value.day}"

    if isinstance(value, str):
        return value

    if isinstance(value, (int, float)):
        # Se for número inteiro, remover .0
        if float(value).is_integer():
            return str(int(value))
        return str(value)

    return str(value)


def is_superset(exercise_name):
    """Verifica se o exercício é parte de um SuperSet"""
    return "SUPERSET A" in exercise_name.upper()


def get_superset_order(exercise_name):
    """Extrai a ordem do SuperSet (A1, A2, etc.) do nome do exercício"""
    if "A1" in exercise_name:
        return "A1"
    elif "A2" in exercise_name:
        return "A2"
    return None


def extract_program_data(excel_file, program_name):
    """
    Extrai dados de um arquivo Excel para um programa específico.

    Returns:
        dict com 'exercises' e 'variations'
    """
    print(f"\n{'='*60}")
    print(f"Extraindo dados de: {excel_file}")
    print(f"Programa: {program_name}")
    print(f"{'='*60}\n")

    # Ler as duas sheets
    df_structured = pd.read_excel(excel_file, sheet_name="Export Structured")
    df_sets = pd.read_excel(excel_file, sheet_name="Export Sets")

    print(f"Export Structured: {len(df_structured)} linhas")
    print(f"Export Sets: {len(df_sets)} linhas")

    # Agrupar por exercício
    exercises = {}
    variations = {}

    # Mapear days
    day_map = DAY_MAP_4DAY if program_name == "4-day" else DAY_MAP_5DAY

    # Processar Export Structured
    for _, row in df_structured.iterrows():
        day = row['Day']
        exercise_name = row['Exercise']
        variation_idx = row['VariationIndex']
        variation_name = row['VariationName']
        youtube_url = row['YouTubeURL']

        # Criar chave única para o exercício
        ex_key = f"{day}|{exercise_name}"

        # Se VariationIndex == 1.0, é o exercício principal
        if variation_idx == 1.0:
            if ex_key not in exercises:
                # Buscar sets e reps do Export Sets
                sets_data = df_sets[
                    (df_sets['Day'] == day) &
                    (df_sets['Exercise'] == exercise_name)
                ]

                # Número de sets únicos
                num_sets = len(sets_data['Set'].unique()) if not sets_data.empty else 3

                # RepsTarget do primeiro set (assumindo que é consistente)
                reps_target = "8-10"  # default
                if not sets_data.empty:
                    first_reps = sets_data.iloc[0]['RepsTarget']
                    reps_target = parse_reps_target(first_reps)

                exercises[ex_key] = {
                    'name': exercise_name,
                    'day': day,
                    'dayIndex': day_map.get(day, 1),
                    'program': program_name,
                    'programId': PROGRAM_MAP[program_name],
                    'sets': num_sets,
                    'repsTarget': reps_target,
                    'youtubeUrl': youtube_url if pd.notna(youtube_url) else None,
                    'isSuperset': is_superset(exercise_name),
                    'supersetOrder': get_superset_order(exercise_name),
                }

            # Adicionar variação primária
            var_key = f"{ex_key}|{variation_idx}"
            variations[var_key] = {
                'exercise_key': ex_key,
                'variationIndex': int(variation_idx),
                'variationName': variation_name,
                'youtubeUrl': youtube_url if pd.notna(youtube_url) else None,
                'isPrimary': True,
            }
        else:
            # Variações alternativas
            var_key = f"{ex_key}|{variation_idx}"
            variations[var_key] = {
                'exercise_key': ex_key,
                'variationIndex': int(variation_idx),
                'variationName': variation_name,
                'youtubeUrl': youtube_url if pd.notna(youtube_url) else None,
                'isPrimary': False,
            }

    print(f"\nExercícios únicos extraídos: {len(exercises)}")
    print(f"Variações extraídas: {len(variations)}")

    return {
        'exercises': exercises,
        'variations': variations
    }


def assign_superset_pair_ids(exercises):
    """
    Atribui supersetPairId para exercícios que fazem parte de SuperSets.
    SuperSets com mesmo prefixo (ex: "SUPERSET A") compartilham o mesmo ID.
    """
    superset_counter = 1
    superset_pairs = {}

    for ex_key, ex_data in exercises.items():
        if ex_data['isSuperset']:
            # Extrair prefixo do SuperSet (ex: "SUPERSET A")
            name = ex_data['name']
            # Assumir formato: "SUPERSET A - Exercise Name (A1)" ou similar
            if "SUPERSET A" in name:
                prefix = f"{ex_data['day']}|SUPERSET A"

                if prefix not in superset_pairs:
                    superset_pairs[prefix] = superset_counter
                    superset_counter += 1

                ex_data['supersetPairId'] = superset_pairs[prefix]

    return exercises


def generate_dart_code(data_4day, data_5day):
    """
    Gera código Dart para adicionar ao mock_data.dart
    """
    exercise_id = EXERCISE_ID_START
    variation_id = VARIATION_ID_START

    # Mapear exercise_key para exercise_id
    exercise_id_map = {}

    # Combinar todos os exercícios
    all_exercises = {}
    all_exercises.update(data_4day['exercises'])
    all_exercises.update(data_5day['exercises'])

    # Atribuir supersetPairId
    all_exercises = assign_superset_pair_ids(all_exercises)

    # Gerar código de exercícios
    exercises_code = []
    exercises_code.append("  // ======================================")
    exercises_code.append("  // EXERCÍCIOS DOS PROGRAMAS 4-DAY E 5-DAY")
    exercises_code.append("  // ======================================")
    exercises_code.append("")

    # Agrupar por programa
    for program in ["4-day", "5-day"]:
        program_exercises = {k: v for k, v in all_exercises.items() if v['program'] == program}

        if not program_exercises:
            continue

        exercises_code.append(f"  // {program.upper()} PROGRAM")

        # Agrupar por dia
        days = sorted(set(ex['day'] for ex in program_exercises.values()),
                     key=lambda d: program_exercises[next(k for k, v in program_exercises.items() if v['day'] == d)]['dayIndex'])

        for day in days:
            day_exercises = {k: v for k, v in program_exercises.items() if v['day'] == day}
            exercises_code.append(f"  // {day}")

            for ex_key in sorted(day_exercises.keys()):
                ex = day_exercises[ex_key]
                exercise_id_map[ex_key] = exercise_id

                # Construir linha do Exercise
                params = [
                    f"id: {exercise_id}",
                    f'name: "{ex["name"]}"',
                    f'day: "{ex["day"]}"',
                    f'program: "{ex["program"]}"',
                    f'sets: {ex["sets"]}',
                    f'repsTarget: "{ex["repsTarget"]}"',
                ]

                if ex['youtubeUrl']:
                    params.append(f'youtubeUrl: "{ex["youtubeUrl"]}"')

                if ex['isSuperset']:
                    params.append(f'isSuperset: true')
                    if 'supersetPairId' in ex:
                        params.append(f'supersetPairId: {ex["supersetPairId"]}')
                    if ex['supersetOrder']:
                        params.append(f'supersetOrder: "{ex["supersetOrder"]}"')

                exercises_code.append(f"  Exercise({', '.join(params)}),")
                exercise_id += 1

            exercises_code.append("")

    # Gerar código de variações
    variations_code = []
    variations_code.append("  // ======================================")
    variations_code.append("  // VARIAÇÕES DOS PROGRAMAS 4-DAY E 5-DAY")
    variations_code.append("  // ======================================")
    variations_code.append("")

    # Combinar todas as variações
    all_variations = {}
    all_variations.update(data_4day['variations'])
    all_variations.update(data_5day['variations'])

    # Agrupar por exercício
    for ex_key, ex_id in exercise_id_map.items():
        ex_variations = {k: v for k, v in all_variations.items() if v['exercise_key'] == ex_key}

        if not ex_variations:
            continue

        ex_name = all_exercises[ex_key]['name']
        variations_code.append(f"  // {ex_name} (id: {ex_id})")

        for var_key in sorted(ex_variations.keys(), key=lambda k: all_variations[k]['variationIndex']):
            var = ex_variations[var_key]

            params = [
                f"id: {variation_id}",
                f"exerciseId: {ex_id}",
                f'variationIndex: {var["variationIndex"]}',
                f'variationName: "{var["variationName"]}"',
            ]

            if var['youtubeUrl']:
                params.append(f'youtubeUrl: "{var["youtubeUrl"]}"')

            if var.get('isPrimary', False):
                params.append('isPrimary: true')

            variations_code.append(f"  ExerciseVariation({', '.join(params)}),")
            variation_id += 1

        variations_code.append("")

    # Combinar tudo
    full_code = []
    full_code.extend(exercises_code)
    full_code.append("")
    full_code.extend(variations_code)

    return '\n'.join(full_code)


def main():
    """Função principal"""
    print("\n" + "="*60)
    print("EXTRAÇÃO DE DADOS DOS EXCEL FILES")
    print("="*60)

    # Verificar se os arquivos existem
    if not FILE_4DAY.exists():
        print(f"❌ Arquivo não encontrado: {FILE_4DAY}")
        return

    if not FILE_5DAY.exists():
        print(f"❌ Arquivo não encontrado: {FILE_5DAY}")
        return

    # Extrair dados
    data_4day = extract_program_data(FILE_4DAY, "4-day")
    data_5day = extract_program_data(FILE_5DAY, "5-day")

    # Gerar código Dart
    print("\n" + "="*60)
    print("GERANDO CÓDIGO DART")
    print("="*60)

    dart_code = generate_dart_code(data_4day, data_5day)

    # Salvar em arquivo
    output_file = Path("generated_exercises.dart")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(dart_code)

    print(f"\n✅ Código gerado e salvo em: {output_file}")
    print(f"   Próximos Exercise IDs começam em: {EXERCISE_ID_START}")
    print(f"   Próximos Variation IDs começam em: {VARIATION_ID_START}")
    print("\nAgora você pode:")
    print("1. Revisar o arquivo generated_exercises.dart")
    print("2. Copiar o conteúdo para mock_data.dart na posição adequada")
    print("3. Executar flutter analyze para verificar erros")


if __name__ == "__main__":
    main()
