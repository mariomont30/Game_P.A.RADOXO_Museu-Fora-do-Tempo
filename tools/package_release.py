"""Package the Windows export and editable project, checking ZIP CRCs and SHA-256."""
from pathlib import Path
import hashlib
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build' / 'windows'
DIST = ROOT / 'dist'

def package() -> None:
    for name in ('PARADOXO.exe', 'PARADOXO.pck'):
        path = BUILD / name
        if not path.is_file() or path.stat().st_size == 0:
            raise FileNotFoundError(f'Missing Windows export: {path}')
    DIST.mkdir(exist_ok=True)
    licenses = BUILD / 'licenses'
    licenses.mkdir(exist_ok=True)
    for name in ('GODOT-LICENSE.txt', 'THIRD-PARTY-LICENSES.json', 'OFL-Symbols.txt', 'OFL-Emoji.txt'):
        shutil.copy2(ROOT / 'licenses' / name, licenses / name)
    (BUILD / 'LEIA-ME.txt').write_text(
        'P.A.RADOXO — O Museu Fora do Tempo\n\n'
        'Windows de 64 bits. Extraia todos os arquivos antes de jogar.\n'
        'Abra PARADOXO.exe e mantenha PARADOXO.pck na mesma pasta.\n'
        'Clique em Entrar no museu e aguarde a preparação.\n'
        'Nao e necessario instalar o Godot. Depois do download, jogue sem internet.\n'
        'Requer suporte a OpenGL 3.3. Executavel sem assinatura digital.\n\n'
        'Setas ou clique: caminhar. E ou Examinar: abrir uma obra.\n'
        'Esc ou Enter: pausar/retomar. F11: tela cheia/janela.\n'
        'Menus: setas e Espaco. Textos com foco: setas e Page Up/Down.\n\n'
        'Cada coração vermelho é uma vida: três no Normal e dois no Difícil.\n'
        'Acertar recupera os corações e renova a tentativa extra.\n'
        'Próxima pergunta mantém as vidas e a tentativa extra que restam.\n'
        'Uma segunda derrota antes do acerto apaga a jornada atual.\n\n'
        'Jogue online: https://mariomont30.github.io/Game_P.A.RADOXO_Museu-Fora-do-Tempo/\n'
        'Guia: https://github.com/mariomont30/Game_P.A.RADOXO_Museu-Fora-do-Tempo/blob/gh-pages/docs/GUIA-DO-JOGADOR.md\n'
        'O progresso e local ao dispositivo; nao ha sincronizacao entre Web e Windows.\n', encoding='utf-8')
    targets = [('PARADOXO-Windows.zip', [(p, Path('PARADOXO-Windows') / p.relative_to(BUILD)) for p in BUILD.rglob('*') if p.is_file()])]
    source = []
    for folder in ('game', 'docs', 'licenses', 'media', 'tools', 'tests'):
        for p in (ROOT / folder).rglob('*'):
            if p.is_file() and not any(part in ('.godot', 'Godot', '__pycache__', 'node_modules', 'test-results') for part in p.relative_to(ROOT).parts):
                source.append((p, Path('PARADOXO-Projeto') / p.relative_to(ROOT)))
    for name in ('README.md', '.gitignore', '.gitattributes'):
        source.append((ROOT / name, Path('PARADOXO-Projeto') / name))
    targets.append(('PARADOXO-Projeto.zip', source))
    checksums = []
    for name, files in targets:
        output = DIST / name
        with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
            for path, arcname in sorted(files, key=lambda item: str(item[1])):
                archive.write(path, arcname.as_posix())
        with zipfile.ZipFile(output) as archive:
            if archive.testzip() is not None:
                raise ValueError(f'ZIP CRC failed: {name}')
        digest = hashlib.sha256(output.read_bytes()).hexdigest()
        checksums.append(f'{digest}  {name}')
        print(f'{name}: {output.stat().st_size:,} bytes; CRC OK; SHA256 {digest}')
    (DIST / 'SHA256SUMS.txt').write_text('\n'.join(checksums) + '\n', encoding='utf-8')

if __name__ == '__main__':
    package()
